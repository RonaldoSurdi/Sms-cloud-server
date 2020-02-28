class AddTypeToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :message_type, :integer
    add_index :messages, :message_type
  end
end
