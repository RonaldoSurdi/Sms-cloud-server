class AddDefaultValueToCadastroAprovado < ActiveRecord::Migration
  def up
    change_column :representatives, :cadastro_aprovado, :boolean, default: false
  end

  def down
    change_column :representatives, :cadastro_aprovado, :boolean, default: nil
  end
end
