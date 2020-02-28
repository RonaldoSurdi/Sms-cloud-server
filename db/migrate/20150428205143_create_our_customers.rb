class CreateOurCustomers < ActiveRecord::Migration
  def change
    create_table :our_customers do |t|
      t.string :descricao
      t.string :url

      t.timestamps
    end
  end
end
