class AddAttempsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :attemps, :integer
  end
end
