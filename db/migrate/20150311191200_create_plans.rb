class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.integer :tipo
      t.integer :quantidade_sms, null: false, default: 0
      t.decimal :valor_total, scale: 2, precision: 12
      t.string :descricao

      t.timestamps
    end
  end
end
