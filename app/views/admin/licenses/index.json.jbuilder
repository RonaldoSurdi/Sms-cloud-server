json.array!(@licenses) do |license|
  json.extract! license, :id, :descricao

  json.plans(descricao: license.plan.descricao)
  json.tipo t(license.tipo, scope: "tipo_licenca")
  json.valor_unitario license.valor_unitario.real_contabil
  json.valor_sugerido license.valor_sugerido.real_contabil

  json.url license_url(license, format: :json)
  json.edit_html_url edit_license_url(license)
  json.show_html_url license_url(license)
end
