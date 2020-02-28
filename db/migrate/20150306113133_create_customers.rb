class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :nome
      t.string :telefone
      t.string :celular
      t.integer :tipo_pessoa
      t.references :endereco, index: true
      t.references :representative, index: true
      t.string :cpf_cnpj
      t.string :razao_social
      t.integer :status, default: Customer.statuses[:ok], null: :false

      t.timestamps
    end
  end
end
