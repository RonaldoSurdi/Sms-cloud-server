class AddMainAdministratorToAdministrators < ActiveRecord::Migration
  def change
    add_column :administrators, :main_administrator, :boolean, default: false, null: false
  end
end
