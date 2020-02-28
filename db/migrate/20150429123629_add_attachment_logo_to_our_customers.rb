class AddAttachmentLogoToOurCustomers < ActiveRecord::Migration
  def self.up
    change_table :our_customers do |t|
      t.attachment :logo
    end
  end

  def self.down
    remove_attachment :our_customers, :logo
  end
end
