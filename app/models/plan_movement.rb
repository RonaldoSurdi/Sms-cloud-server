class PlanMovement < ActiveRecord::Base
  belongs_to :license_movement
  belongs_to :customer

  enum plano_tipo: Plan.tipos

  validates :customer_id, :quantidade_sms, :plano_valor_total, :validade_inicio, :validade_fim, presence: true
  validates :license_movement_id, presence: true, if: :licenca?
  validates :quantidade_sms, :plano_valor_total, numericality: { greater_than: 0 }
  validates :quantidade_sms, numericality: { only_integer: true }

  scope :filter, -> (filter) {
    filter = "%#{filter}%"
    where { (plano_descricao =~ filter) | (customer.nome =~ filter) }
  }

  scope :avulso_ou_adicional, -> { where{(plano_tipo == Plan.tipos[:avulso]) | (plano_tipo == Plan.tipos[:adicional])} }

  scope :vencidas, -> { where "validade_fim < :hoje", hoje: Date.today  }
  scope :nao_vencidas, -> { where ":hoje BETWEEN validade_inicio AND validade_fim", hoje: Date.today }

  scope :confirmadas, -> { where.not confirmado_pagamento_em: nil }
  scope :nao_confirmadas, -> { where confirmado_pagamento_em: nil }

  scope :por_status, -> (status) {
    if status.try(:to_sym).try(:==, :confirmadas)
      confirmadas
    elsif status.try(:to_sym).try(:==, :aguardando)
      nao_confirmadas
    elsif status.try(:to_sym).try(:==, :todas)
      where("")
    end
  }

  def confirmada?
    self.confirmado_pagamento_em.present?
  end

  def vencida?
    self.validade_fim.try(:<, Date.today)
  end

  def avulso_ou_adicional?
    self.try(:avulso?) || self.try(:adicional?)
  end

  def confirmar
    self.update(PlanMovement.atributos_para_confirmar_movimentacao_de_plano)
  end

  def self.validade
    1.year
  end

  def self.confirmar_todos(plan_movements)
    plan_movements.update_all(PlanMovement.atributos_para_confirmar_movimentacao_de_plano)
  end

  def self.gerar_movimentos_de_planos_para_a_licenca(license_movement)
    PlanMovement.transaction do
      movimentacao_plano = PlanMovement.new license_movement_id: license_movement.id,
        customer_id: license_movement.customer_id,
        quantidade_sms: license_movement.plano_quantidade_sms,
        plano_valor_total: license_movement.plano_valor_total,
        plano_tipo: Plan.tipos[:licenca],
        validade_inicio: license_movement.validade_inicio - PlanMovement.validade,
        validade_fim: license_movement.validade_inicio

      quantidade = (LicenseMovement.validade / PlanMovement.validade).to_i
      quantidade.to_i.times do |i|
        copia = movimentacao_plano.dup
        copia.assign_attributes(validade_inicio: copia.validade_inicio + PlanMovement.validade,
                                validade_fim: (copia.validade_fim + PlanMovement.validade) - 1.day)

        movimentacao_plano = copia.dup
        movimentacao_plano.validade_fim += 1.day
        copia.save!
      end
    end
  end

  def self.criar_pacote_sms(plan, customer)
    hoje = Date.today

    PlanMovement.create customer: customer,
                        quantidade_sms: plan.quantidade_sms,
                        plano_valor_total: plan.valor_total,
                        plano_descricao: plan.descricao,
                        plano_tipo: plan.tipo,
                        validade_inicio: hoje,
                        validade_fim: hoje + PlanMovement.validade - 1.day
  end

  private

  def self.atributos_para_confirmar_movimentacao_de_plano
    hoje = Date.today

    {
      confirmado_pagamento_em: hoje,
      validade_inicio: hoje,
      validade_fim: hoje + PlanMovement.validade - 1.day
    }
  end
end
