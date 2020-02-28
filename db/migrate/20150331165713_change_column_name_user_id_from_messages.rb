class ChangeColumnNameUserIdFromMessages < ActiveRecord::Migration
  def change
    remove_foreign_key :messages, :users
    remove_column :messages, :user_id
    add_reference :messages, :customer, index: true
    add_foreign_key :messages, :customers
  end
end
