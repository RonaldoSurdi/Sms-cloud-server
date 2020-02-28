class AddUuidToMessages < ActiveRecord::Migration
  def up
    add_column :messages, :uuid, :string, index: true

    Message.find_each do |message|
      message.send(:generate_uuid)
      message.save!
    end
  end

  def down
    remove_column :messages, :uuid
  end
end
