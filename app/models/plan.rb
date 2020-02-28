class Plan < ActiveRecord::Base
  include Formatador
  include Calculos

  decimal_value :valor_total

  enum tipo: [:licenca, :adicional, :avulso]

  has_many :licenses

  validates :tipo, :valor_total, :descricao, :quantidade_sms, presence: true
  validates :valor_total, numericality: { greater_than: 0 }
  validates :quantidade_sms, numericality: { greater_than: 0, only_integer: true }

  scope :filter, ->(filter) {
    where("descricao ILike :filter", filter: "%#{filter}%") unless filter.blank?
  }

  scope :nao_avulso, -> { where.not tipo: tipos[:avulso] }
  scope :para_licenca, -> { where tipo: tipos[:licenca] }
  scope :avulso, -> { where tipo: tipos[:avulso] }
  scope :adicional, -> { where tipo: tipos[:adicional] }

  def valor_unitario
    formatar_dinheiro calcular_valor_unitario(self.valor_total, self.quantidade_sms), 5
  end

  def validade
    1.year
  end
end
