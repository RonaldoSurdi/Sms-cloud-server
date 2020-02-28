class CreateContactGroups < ActiveRecord::Migration
  def change
    create_table :contact_groups do |t|
      t.string :descricao
      t.string :observacao
      t.references :customer, index: true

      t.timestamps

      t.foreign_key :customers
    end
  end
end
