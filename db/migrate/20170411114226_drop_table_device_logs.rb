class DropTableDeviceLogs < ActiveRecord::Migration
  def up
    drop_table :device_logs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
