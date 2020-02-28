class AddActiveToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :active, :boolean, default: false, null: :false
  end
end
