class CreateConfigurations < ActiveRecord::Migration
  def up
    create_table :configurations do |t|
      t.references :customer, index: true

      t.boolean :send_birthdays, null: false, default: false
      t.string :text_birthdays
    end

    add_foreign_key :configurations, :customers

    Customer.find_each do |customer|
      Configuration.create customer_id: customer.id
    end
  end

  def down
    remove_foreign_key :configurations, :customers
    drop_table :configurations
  end
end
