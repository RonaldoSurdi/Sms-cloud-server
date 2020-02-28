class CreateRepresentatives < ActiveRecord::Migration
  def change
    create_table :representatives do |t|
      t.string :razao_social
      t.string :nome_fantasia
      t.string :cnpj
      t.string :inscricao_estadual
      t.string :responsavel
      t.string :telefone
      t.string :celular
      t.boolean :cadastro_aprovado, default: false, null: false
      t.references :endereco, index: true

      t.timestamps
    end
  end
end