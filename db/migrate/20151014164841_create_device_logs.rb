class CreateDeviceLogs < ActiveRecord::Migration
  def change
    create_table :device_logs do |t|
      t.string :message_log
      t.references :device, index: true

      t.timestamps
    end
  end
end
