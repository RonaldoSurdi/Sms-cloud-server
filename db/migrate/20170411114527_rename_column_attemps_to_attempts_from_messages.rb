class RenameColumnAttempsToAttemptsFromMessages < ActiveRecord::Migration
  def change
    rename_column :messages, :attemps, :attempts
  end
end
