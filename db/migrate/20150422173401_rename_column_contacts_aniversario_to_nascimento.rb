class RenameColumnContactsAniversarioToNascimento < ActiveRecord::Migration
  def change
    rename_column :contacts, :aniversario, :nascimento
  end
end
