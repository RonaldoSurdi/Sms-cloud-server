class AddAndChangeAttributesOfPlanMovements < ActiveRecord::Migration
  def up
    add_column :plan_movements, :plano_descricao, :string
    add_column :plan_movements, :plano_tipo, :integer
    add_column :plan_movements, :confirmado_pagamento_em, :date
    add_column :plan_movements, :created_at, :datetime

    rename_column :plan_movements, :valor_plano, :plano_valor_total

    PlanMovement.transaction do
      PlanMovement.includes(:license_movement).references(:all).each do |pm|
        pm.update! created_at: pm.license_movement.created_at,
                    plano_tipo: Plan.tipos[:licenca],
                    plano_descricao: pm.license_movement.plano_descricao
      end
    end
  end

  def down
    remove_column :plan_movements, :plano_descricao, :string
    remove_column :plan_movements, :plano_tipo, :integer
    remove_column :plan_movements, :confirmado_pagamento_em, :date
    remove_column :plan_movements, :created_at, :datetime

    rename_column :plan_movements, :plano_valor_total, :valor_plano
  end
end
