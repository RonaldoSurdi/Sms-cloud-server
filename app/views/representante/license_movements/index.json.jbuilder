json.array!(@license_movements) do |license_movement|
  json.extract! license_movement, :id, :licenca_descricao

  json.created_at license_movement.created_at.to_date.to_s_br
  json.data_venda_cliente(license_movement.data_venda_cliente.to_s_br)

  if license_movement.confirmada?
    json.status(icon: 'icon-check text-success', title: 'Compra confirmada')
  else
    json.status(icon: 'icon-refresh text-warning', title: 'Compra aguardando confirmação')
  end

  json.licenca_tipo t(license_movement.licenca_tipo, scope: "tipo_licenca")
  json.licenca_valor_unitario license_movement.licenca_valor_unitario.real_contabil
  json.licenca_valor_sugerido license_movement.licenca_valor_sugerido.real_contabil
  json.valor_venda_cliente license_movement.valor_venda_cliente.real_contabil

  json.url representative_license_movement_url(license_movement, format: :json)
  json.show_html_url representative_license_movement_url(license_movement)
end
