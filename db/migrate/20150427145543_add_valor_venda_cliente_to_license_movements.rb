class AddValorVendaClienteToLicenseMovements < ActiveRecord::Migration
  def up
    add_column :license_movements, :valor_venda_cliente, :decimal, scale: 2, precision: 12

    LicenseMovement.transaction do
      LicenseMovement.all.each do |movement|
        movement.update! valor_venda_cliente: movement.licenca_valor_sugerido if movement.vendida?
      end
    end
  end

  def down
    remove_column :license_movements, :valor_venda_cliente, :decimal, scale: 2, precision: 12
  end
end
