class CreateLicenses < ActiveRecord::Migration
  def change
    create_table :licenses do |t|
      t.decimal :valor_unitario, scale: 2, precision: 12
      t.decimal :valor_sugerido, scale: 2, precision: 12
      t.integer :tipo, null: false, default: 0
      t.references :plan, index: true

      t.timestamps
    end
  end
end
