json.array!(@license_movements) do |license_movement|
  json.extract! license_movement, :id, :licenca_descricao

  json.created_at license_movement.created_at.to_s_br

  json.representante(nome_fantasia: license_movement.representative.nome_fantasia)

  if params[:status] == 'aguardando'
    if (can?(:update, LicenseMovement) || can?(:destroy, LicenseMovement))
      json.status(title: 'Compra aguardando confirmação')
    end
  else
    if license_movement.confirmada?
      json.status(icon: 'icon-check text-success', title: 'Compra confirmada')
    else
      json.status(icon: 'icon-refresh text-warning', title: 'Compra aguardando confirmação')
    end
  end

  json.licenca_tipo t(license_movement.licenca_tipo, scope: "tipo_licenca")
  json.licenca_valor_unitario license_movement.licenca_valor_unitario.real_contabil
  json.licenca_valor_sugerido license_movement.licenca_valor_sugerido.real_contabil

  json.url license_movement_url(license_movement, format: :json)
  json.show_html_url license_movement_url(license_movement)
end
