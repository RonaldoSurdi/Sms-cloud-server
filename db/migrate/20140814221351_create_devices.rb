class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :description
      t.text :gcm_registration_id, unique: true
      t.datetime :last_activity

      t.timestamps
    end
  end
end
