class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :nome
      t.string :celular
      t.string :email
      t.string :empresa
      t.references :customer, index: true

      t.timestamps

      t.foreign_key :customers
    end
  end
end
