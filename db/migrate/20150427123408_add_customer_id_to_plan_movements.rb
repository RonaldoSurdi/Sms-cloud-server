class AddCustomerIdToPlanMovements < ActiveRecord::Migration
  def up
    add_column :plan_movements, :customer_id, :integer, references: :customers
    add_foreign_key :plan_movements, :customers

    PlanMovement.transaction do
      PlanMovement.includes(:license_movement).each do |plan|
        plan.update! customer_id: plan.license_movement.customer_id
      end
    end
  end

  def down
    remove_foreign_key :plan_movements, :customers
    remove_column :plan_movements, :customer_id, :integer, references: :customers
  end
end
