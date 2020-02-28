class LicenseMovement < ActiveRecord::Base
  include Formatador
  include Calculos

  decimal_value :valor_venda_cliente

  belongs_to :license
  belongs_to :representative
  belongs_to :customer
  has_many :plan_movements

  enum licenca_tipo: License.tipos

  validates :license_id, :licenca_descricao, :licenca_tipo, :licenca_valor_unitario, :licenca_valor_sugerido, :valor_venda_cliente, presence: true
  validates :licenca_valor_unitario, :licenca_valor_sugerido, numericality: { greater_than: 0 }

  scope :representative_filter, ->(filter) {
    where("licenca_descricao ILike :filter", filter: "%#{filter}%") unless filter.blank?
  }
  scope :filter, ->(filter) {
    where("licenca_descricao ILike :filter OR representatives.nome_fantasia ILike :filter", filter: "%#{filter}%") unless filter.blank?
  }

  scope :por_status, -> (status) {
    if status.try(:to_sym).try(:==, :para_venda)
      confirmadas.nao_vendidas
    elsif status.try(:to_sym).try(:==, :vendidas)
      confirmadas.vendidas
    elsif status.try(:to_sym).try(:==, :aguardando)
      nao_confirmadas
    elsif status.try(:to_sym).try(:==, :todas)
      where("")
    end
  }

  scope :unicas, -> {
    select("license_id, COUNT(*) AS quantidade, licenca_descricao, licenca_valor_sugerido, plano_descricao, plano_quantidade_sms")
      .group("license_id, licenca_descricao, licenca_valor_sugerido, plano_descricao, plano_quantidade_sms")
  }

  scope :por_representante, -> (id) { where representative_id: id }

  scope :confirmadas, -> { where.not confirmado_pagamento_em: nil }
  scope :nao_confirmadas, -> { where confirmado_pagamento_em: nil }

  scope :vendidas, -> { where.not data_venda_cliente: nil }
  scope :nao_vendidas, -> { where data_venda_cliente: nil }

  def confirmada?
    self.confirmado_pagamento_em.present?
  end

  def vendida?
    self.data_venda_cliente.present?
  end

  def vencida?
    self.validade_fim.try(:<, Date.today)
  end

  def vencendo?
    Date.today.between?(self.validade_fim - LicenseMovement.periodo_vencendo, self.validade_fim) if self.vendida?
  end

  def licenca_reserva?
    self.try(:validade_inicio).try(:>, Date.today)
  end

  def confirmar
    self.update(confirmado_pagamento_em: DateTime.current)
  end

  def gerar(params)
    self.valor_venda_cliente = ""

    ActiveRecord::Base.transaction do
      licencas = License.includes(:plan).where id: params.select{ |k,v| v.to_i > 0 }.keys.collect(&:to_i)
      licencas.each do |licenca|
        quantidade = params[licenca.id.to_s].to_i
        quantidade.times do
          nova_movimentacao = self.dup
          nova_movimentacao.assign_attributes license_id: licenca.id, licenca_descricao: licenca.descricao, licenca_tipo: licenca.tipo,
              licenca_valor_unitario: licenca.valor_unitario, licenca_valor_sugerido: licenca.valor_sugerido,
              plano_descricao: licenca.plan.descricao, plano_quantidade_sms: licenca.plan.quantidade_sms, plano_valor_total: licenca.plan.valor_total

          nova_movimentacao.save
        end
      end
    end
  end

  def vender_para_cliente(customer)
    self.customer_id = customer.id
    data_inicio_validade = Date.today

    if (customer.license_movements.any? && (current_license_movement = customer.current_license_movement) && current_license_movement.vencendo?)
      data_inicio_validade = current_license_movement.validade_fim + 1.day
    end

    self.assign_attributes data_venda_cliente: Date.today, validade_inicio: data_inicio_validade, validade_fim: data_inicio_validade + LicenseMovement.validade
    self.save
  end

  def self.confirm_sales(sales)
    updated_count = where(id: sales.collect(&:id)).update_all(confirmado_pagamento_em: DateTime.current)
    updated_count > 0
  end

  def self.destroy_sales(sales)
    deleted_count = where(id: sales.collect(&:id)).delete_all
    deleted_count > 0
  end

  def self.validade
    1.year - 1.day
  end

  def self.periodo_vencendo
    3.months
  end
end
