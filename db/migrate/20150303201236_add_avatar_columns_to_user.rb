class AddAvatarColumnsToUser < ActiveRecord::Migration
  def self.up
    add_attachment :representatives, :logo
  end

  def self.down
    remove_attachment :representatives, :logo
  end
end
