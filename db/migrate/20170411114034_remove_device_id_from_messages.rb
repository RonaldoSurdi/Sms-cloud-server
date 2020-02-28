class RemoveDeviceIdFromMessages < ActiveRecord::Migration
  def up
    remove_foreign_key :messages, :devices
    remove_column :messages, :device_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
