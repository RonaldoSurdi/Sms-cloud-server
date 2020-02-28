class AddSexoToContacts < ActiveRecord::Migration
  def up
    add_column :contacts, :sexo, :integer, null: false, default: 0

    Contact.transaction do
      Contact.all.each do |contact|
        contact.update! sexo: rand(2), nascimento: Date.yesterday
      end
    end
  end

  def down
    remove_column :contacts, :sexo, :integer, null: false, default: 0
  end
end
