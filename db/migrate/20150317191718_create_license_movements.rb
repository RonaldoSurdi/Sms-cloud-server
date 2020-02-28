class CreateLicenseMovements < ActiveRecord::Migration
  def change
    create_table :license_movements do |t|
      t.references :license, index: true
      t.references :representative, index: true
      t.datetime :confirmado_pagamento_em
      t.string :licenca_descricao
      t.integer :licenca_tipo
      t.decimal :licenca_valor_unitario, scale: 2, precision: 12, null: false, default: 0
      t.decimal :licenca_valor_sugerido, scale: 2, precision: 12, null: false, default: 0

      t.timestamps
    end
  end
end
