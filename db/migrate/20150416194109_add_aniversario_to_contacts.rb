class AddAniversarioToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :aniversario, :date
  end
end
