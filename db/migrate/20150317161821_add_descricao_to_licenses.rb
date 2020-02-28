class AddDescricaoToLicenses < ActiveRecord::Migration
  def change
    add_column :licenses, :descricao, :string
  end
end
