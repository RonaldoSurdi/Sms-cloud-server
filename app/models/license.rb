class License < ActiveRecord::Base

  decimal_value :valor_unitario, :valor_sugerido

  belongs_to :plan

  enum tipo: [:nova, :renovacao]

  validates :descricao, :tipo, :valor_unitario, :valor_sugerido, :plan_id, presence: true
  validates :valor_unitario, numericality: { greater_than: 0 }
  validates :valor_sugerido, numericality: { greater_than: 0 }
  validate :plano_nao_avulso

  scope :filter, ->(filter) {
    where("licenses.descricao ILike :filter OR plans.descricao ILike :filter", filter: "%#{filter}%") unless filter.blank?
  }

  scope :por_tipo, -> (tipo) {
    if tipo.to_sym == :nova
      where(tipo: tipos[:nova])
    elsif tipo.to_sym == :renovacao
      where(tipo: tipos[:renovacao])
    end
  }

  private

  def plano_nao_avulso
    errors.add(:plan_id, "Plano inválido!") if self.plan.try(:avulso?)
  end
end
