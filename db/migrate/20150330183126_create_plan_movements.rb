class CreatePlanMovements < ActiveRecord::Migration
  def change
    create_table :plan_movements do |t|
      t.references :license_movement, index: true
      t.integer :quantidade_sms
      t.decimal :valor_plano, scale: 2, precision: 12
      t.date :validade_inicio
      t.date :validade_fim
    end
  end
end
