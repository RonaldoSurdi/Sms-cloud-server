class CreateMessageGroups < ActiveRecord::Migration
  def change
    create_table :message_groups do |t|

      t.timestamps
    end
  end
end
