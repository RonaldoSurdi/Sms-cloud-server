class AddCustomerToLicenseMovements < ActiveRecord::Migration
  def change
    add_reference :license_movements, :customer, index: true
    add_foreign_key :license_movements, :customers
    add_column :license_movements, :data_venda_cliente, :date
  end
end
