class AddPhoneNumberToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :phone_number, :string
  end
end
