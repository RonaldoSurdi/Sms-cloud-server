class DropTableDevices < ActiveRecord::Migration
  def up
    drop_table :devices
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
