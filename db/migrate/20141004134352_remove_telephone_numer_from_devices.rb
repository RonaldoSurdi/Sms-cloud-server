class RemoveTelephoneNumerFromDevices < ActiveRecord::Migration
  def change
    remove_column :devices, :telephone_numer, :string
  end
end
