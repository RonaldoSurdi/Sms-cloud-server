class AddEliminatedToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :eliminated, :boolean, null: false, default: false
  end
end
