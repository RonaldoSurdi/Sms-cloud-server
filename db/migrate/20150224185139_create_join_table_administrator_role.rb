class CreateJoinTableAdministratorRole < ActiveRecord::Migration
  def change
    create_join_table :administrators, :roles do |t|

    end
  end
end
