class AddColumnDateTimeSentToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :date_time_sent, :datetime, index: true
  end
end
