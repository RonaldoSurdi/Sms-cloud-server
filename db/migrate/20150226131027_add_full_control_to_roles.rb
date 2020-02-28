class AddFullControlToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :full_control, :boolean, default: false, null: false
  end
end
