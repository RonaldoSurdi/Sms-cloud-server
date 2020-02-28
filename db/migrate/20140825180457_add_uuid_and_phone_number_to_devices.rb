class AddUuidAndPhoneNumberToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :uuid, :string
    add_column :devices, :telephone_numer, :string
    add_index :devices, :uuid, unique: true
  end
end
