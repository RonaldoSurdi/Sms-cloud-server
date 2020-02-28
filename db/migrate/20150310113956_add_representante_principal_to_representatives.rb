class AddRepresentantePrincipalToRepresentatives < ActiveRecord::Migration
  def change
    add_column :representatives, :representante_principal, :boolean, null: false, default: false
  end
end
