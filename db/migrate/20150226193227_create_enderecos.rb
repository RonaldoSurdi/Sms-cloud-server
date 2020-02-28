class CreateEnderecos < ActiveRecord::Migration
  def change
    create_table :enderecos do |t|
      t.string :logradouro
      t.string :bairro
      t.string :cidade
      t.string :uf
      t.string :cep
      t.string :complemento, default: ""

      t.timestamps
    end
  end
end
