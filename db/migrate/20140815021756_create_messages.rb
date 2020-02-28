class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :message
      t.string :to, index: true
      t.string :from, index: true
      t.integer :status, index: true
      t.datetime :schedule, index: true
      t.references :device, index: true

      t.timestamps
    end

    add_foreign_key(:messages, :devices)
  end
end
