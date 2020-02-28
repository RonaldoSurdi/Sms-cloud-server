class AddMessageGroupToMessages < ActiveRecord::Migration
  def change
    add_reference :messages, :message_group, index: true
  end
end
