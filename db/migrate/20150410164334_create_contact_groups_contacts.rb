class CreateContactGroupsContacts < ActiveRecord::Migration
  def change
    create_table :contact_groups_contacts, index: false do |t|
      t.belongs_to :contact, index: true
      t.belongs_to :contact_group, index: true
      t.foreign_key :contacts
      t.foreign_key :contact_groups
    end
  end
end
