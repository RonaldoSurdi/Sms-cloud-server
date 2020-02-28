class Customer < ActiveRecord::Base
  include Formatador

  SYMBOL_FOR_NO_LETTER = "1"

  BASE_FILTER_QUERY = "customers.nome ILike :filter OR customers.cpf_cnpj ILike :filter OR " +
                      "customers.telefone ILike :filter OR customers.email ILike :filter"

  only_digits :cpf_cnpj, :telefone, :celular

  devise :database_authenticatable, :recoverable, :trackable, :validatable, :confirmable

  after_create :add_configuration
  before_save :strip_attributes

  belongs_to :endereco, dependent: :destroy
  belongs_to :representative
  has_many :license_movements
  has_many :plan_movements
  has_many :messages
  has_many :contacts
  has_many :contact_groups
  has_one :configuration

  accepts_nested_attributes_for :endereco

  enum status: [:ok, :bloqueado, :eliminado]
  enum tipo_pessoa: [:fisica, :juridica]

  attr_accessor :current_password, :valid_current_password

  validates :nome, :telefone, :email, :tipo_pessoa, :cpf_cnpj, presence: true
  validates :razao_social, presence: true, if: :juridica?
  validates :telefone, length: { minimum: 10 }
  validates :celular, length: { minimum: 10 }, allow_blank: true
  validates :cpf_cnpj, uniqueness: { conditions: -> { email_confirmado.nao_eliminado } }
  validate :full_name_validation
  validate :validar_cpf_cnpj
  validate :authenticate_password, if: :valid_current_password
  validate :verificar_igualdade_de_telefone_e_celular

  scope :filter, -> (filter) {
    joins(:representative)
    .where("#{BASE_FILTER_QUERY} OR representatives.nome_fantasia ILike :filter", filter: "%#{filter}%") unless filter.blank?
  }

  scope :representatives_filter, -> (filter) {
    where(BASE_FILTER_QUERY, filter: "%#{filter}%") unless filter.blank?
  }

  scope :por_status_venda, -> (status_venda = "") {
    if status_venda.try(:to_sym) == :com_licenca
      com_licenca
    elsif status_venda.try(:to_sym) == :sem_licenca
      sem_licenca
    else
      where("")
    end
  }

  scope :com_licenca, -> {
    join_com_licenca_atual
      .where("validade_fim >= Date(Now())")
  }

  scope :sem_licenca, -> {
    join_com_licenca_atual
      .where("(license_movements.data_venda_cliente IS NULL) OR (license_movements.validade_fim < Date(now()))")
  }

  scope :pode_comprar_licenca, -> {
    query_licenca_futura = "Select 1 From license_movements Where customer_id = customers.id And validade_inicio > Date(Now())"
    join_com_licenca_atual
      .where("(license_movements.id Is Null) Or /* Sem Licença */
          (validade_fim < Date(Now())) Or /* Vencida */
          (Date(now()) > license_movements.validade_fim - Interval ':months months' And Not Exists (#{query_licenca_futura})) /* Vencendo */",
              months: (LicenseMovement.periodo_vencendo / 1.month))
  }

  scope :join_com_licenca_atual, -> {
    joins("Left Join (
              Select *
                From license_movements
                Where customer_id Is Not Null
                  And Date(Now()) Between validade_inicio And validade_fim
            ) As license_movements ON license_movements.customer_id = customers.id")
  }

  scope :email_confirmado, -> { where.not confirmed_at: nil }
  scope :nao_eliminado, -> { where.not status: statuses[:eliminado] }
  scope :status_ok, -> { where status: statuses[:ok] }

  scope :to_send_for_birthdays, -> {
    joins(:configuration)
    .where(configuration: {send_birthdays: true})
  }

  scope :contacts_in_birthday, -> {
    joins(:contacts)
    .where("EXTRACT('day' FROM contacts.nascimento) = :day AND EXTRACT('month' FROM contacts.nascimento) = :month",
      day: Date.current.day,
      month: Date.current.month)
  }

  def current_license_movement
    self.license_movements.try(:select) do |license_movement|
      Date.today.between?(license_movement.validade_inicio, license_movement.validade_fim)
    end.try(:sort) do |primeiro, segundo|
      primeiro.validade_inicio <=> segundo.validade_inicio
    end.try(:first)
  end

  def current_plan_movements
    self.plan_movements.try(:select) do |plan_movement|
      Date.today.between?(plan_movement.validade_inicio, plan_movement.validade_fim) && (!plan_movement.avulso_ou_adicional? || plan_movement.confirmada?)
    end.try(:sort) do |primeiro, segundo|
      primeiro.validade_inicio <=> segundo.validade_inicio
    end
  end

  def saldo_sms
    if @saldo_sms
      @saldo_sms
    else
      current_plans = self.current_plan_movements
      if current_plans.present?
        spent_messages_count = self.messages.per_range_date_sent(current_plans.first.validade_inicio, current_plans.last.validade_fim).count
        total_messages_count = current_plans.collect(&:quantidade_sms).inject(:+)

        @saldo_sms = total_messages_count - spent_messages_count
      else
        0
      end
    end
  end

  def possui_saldo?
    self.saldo_sms > 0
  end

  def possui_licenca_atual?
    @possui_licenca ||= self.current_license_movement.present?
    @possui_licenca
  end

  def possui_licenca_reserva?
    self.try(:license_movements).try(:sort) do |primeiro, segundo|
      primeiro.validade_inicio <=> segundo.validade_inicio
    end.try(:last).try(:validade_inicio).try(:>, Date.today)
  end

  def pode_comprar_licenca?
    unless @pode_comprar
      current_license = self.current_license_movement
      @pode_comprar ||= self.ok? && (current_license.blank? || current_license.vencida? || (current_license.vencendo? && !self.possui_licenca_reserva?))
    end

    @pode_comprar
  end

  def cpf_cnpj_formatado
    if (self.cpf_cnpj.size == 11)
      Cpf.new(self.cpf_cnpj).to_s
    else
      Cnpj.new(self.cpf_cnpj).to_s
    end
  end

  def telefone_formatado
    formatar_telefone self.telefone
  end

  def celular_formatado
    formatar_telefone self.celular
  end

  def destroy
    self.update status: :eliminado
  end

  def self.confirm_by_token(confirmation_token)
    ret = nil

    Customer.transaction do
      ret = super
      raise if ret.errors.empty? && ret.invalid?
      ret
    end
  rescue
    ret
  end

  def contacts_with_groups_per_first_letter
    scope = self.contacts_with_groups

    scope.inject({}) do |r, contact|
      key = contact.nome[0].upcase
      letter = key =~ /[[:alpha:]]/
      key = letter ? key : SYMBOL_FOR_NO_LETTER

      r[key] ||= []
      r[key] << contact
      r
    end
  end

  def contacts_with_groups
    contacts
      .select([:id, :nome, :celular, :empresa, :nascimento, :sexo,
        "Array(Select cg.id From contact_groups_contacts cgc Join contact_groups cg On cgc.contact_group_id = cg.id And cgc.contact_id = contacts.id) As groups_ids"])
      .order(:nome)
  end

  private

  def validar_cpf_cnpj
    if self.fisica?
      errors.add(:cpf_cnpj, "CPF inválido") unless Cpf.new(self.cpf_cnpj).valido?
    else self.juridica?
      errors.add(:cpf_cnpj, "CNPJ inválido") unless Cnpj.new(self.cpf_cnpj).valido?
    end
  end

  def verificar_igualdade_de_telefone_e_celular
    errors.add(:celular, "igual ao número de telefone") if self.celular.present? && self.celular == self.telefone
  end

  def authenticate_password
    errors.add(:current_password, "não confere") if self.password.present? && !Customer.find(self.id).valid_password?(@current_password.to_s)
  end

  def full_name_validation
    if self.nome.to_s.split(' ').size <= 1
      errors.add(:nome, "informe o nome completo")
    end
  end

  def strip_attributes
    self.nome = self.nome.strip.gsub("\s\s", "\s").gsub("\s\s", "\s")
  end

  def add_configuration
    Configuration.create! customer_id: self.id
  end
end
