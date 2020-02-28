class CreatePermissions < ActiveRecord::Migration
  def up
    create_table :permissions do |t|
      t.string :subject
      t.string :actions
      t.references :role, index: true

      t.timestamps
    end
  end
end
