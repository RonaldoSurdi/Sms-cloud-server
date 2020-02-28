class AddPlanFieldsAndValidadeInicioAndValidadeFimToLicenseMovements < ActiveRecord::Migration
  def up
    add_column :license_movements, :plano_quantidade_sms, :integer
    add_column :license_movements, :plano_descricao, :string
    add_column :license_movements, :plano_valor_total, :decimal, scale: 2, precision: 12
    add_column :license_movements, :validade_inicio, :date
    add_column :license_movements, :validade_fim, :date

    ActiveRecord::Base.transaction do
      LicenseMovement.includes(:license).each do |license_movement|
        plan = license_movement.license.plan

        license_movement.update! plano_quantidade_sms: plan.quantidade_sms, plano_descricao: plan.descricao, plano_valor_total: plan.valor_total,
            validade_inicio: license_movement.data_venda_cliente, validade_fim: license_movement.data_venda_cliente.try(:+, LicenseMovement.validade)
      end
    end unless LicenseMovement.count.zero?
  end

  def down
    remove_column :license_movements, :plano_quantidade_sms, :integer
    remove_column :license_movements, :plano_descricao, :string
    remove_column :license_movements, :plano_valor_total, :decimal, scale: 2, precision: 12
  end
end
