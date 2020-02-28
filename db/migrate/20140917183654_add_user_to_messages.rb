class AddUserToMessages < ActiveRecord::Migration
  def change
    add_reference :messages, :user, index: true
    add_foreign_key(:messages, :users)
  end
end
