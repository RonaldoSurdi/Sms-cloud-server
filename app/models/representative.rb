class Representative < ActiveRecord::Base

  only_digits :cnpj, :telefone, :celular

  belongs_to :endereco, dependent: :destroy

  accepts_nested_attributes_for :endereco

  has_many :customers
  has_many :license_movements

  has_attached_file :logo, styles: { thumb: "100x100" }

  attr_accessor :current_password, :valid_current_password
  attr_accessor :mensagem

  devise :database_authenticatable, :recoverable, :trackable, :validatable, :confirmable

  validates_attachment_content_type :logo, content_type: /^image\/(bmp|jpg|jpeg|png|gif)/
  validates :logo, attachment_presence: false
  validates :razao_social, :nome_fantasia, :cnpj, :responsavel, :telefone, presence: true
  validates :cnpj, uniqueness: { conditions: -> { where.not(confirmed_at: nil) } }
  validates :telefone, length: { minimum: 10 }
  validates :celular, length: { minimum: 10 }, allow_blank: true
  validates :inscricao_estadual, length: { minimum: 8, message: 'muito curto para ser uma inscrição estadual' }, allow_blank: true
  validate :verificar_igualdade_de_telefone_e_celular
  validate :authenticate_password, if: :valid_current_password
  validate :validar_cnpj

  scope :filter, -> (filter) {
    where("nome_fantasia ILike :filter OR razao_social ILike :filter OR cnpj ILike :filter OR " +
          "responsavel ILike :filter OR telefone ILike :filter OR email ILike :filter",
          filter: "%#{filter}%") unless filter.blank?
  }

  scope :por_status, -> (status) {
    status_sym = status.to_s.to_sym
    if status_sym == :aprovado
      where(cadastro_aprovado: true)
    elsif status_sym == :nao_aprovado
      where(cadastro_aprovado: false)
    elsif status_sym == :todos
      where("")
    end
  }

  scope :por_uf, -> (uf) {
    where("enderecos.uf = ? OR representatives.representante_principal", uf)
  }

  scope :email_confirmado, -> { where.not confirmed_at: nil }

  scope :aprovado, -> { where cadastro_aprovado: true }

  scope :representante_principal, -> { where representante_principal: true }
  scope :nao_representante_principal, -> { where.not representante_principal: true }

  def cnpj_formatado
    Cnpj.new(self.cnpj).to_s
  end

  def telefone_formatado
    sprintf("(%.2s) %.4s-%.5s", self.telefone[0..2], self.telefone[2..6], self.telefone[6..11])
  end

  def celular_formatado
    (self.celular.present?) ? sprintf("(%.2s) %.4s-%.5s", self.celular[0..2], self.celular[2..6], self.celular[6..11]) : ""
  end

  def self.confirm_by_token(confirmation_token)
    ret = nil

    Representative.transaction do
      ret = super
      raise if ret.errors.empty? && ret.invalid?
      ret
    end
  rescue
    ret
  end

  private

  def validar_cnpj
    errors.add(:cnpj, "CNPJ inválido") unless Cnpj.new(self.cnpj).valido?
  end

  def verificar_igualdade_de_telefone_e_celular
    errors.add(:celular, "igual ao número de telefone") if self.celular.present? && self.celular == self.telefone
  end

  def authenticate_password
    errors.add(:current_password, "não confere") if self.password.present? && !Representative.find(self.id).valid_password?(@current_password.to_s)
  end
end
