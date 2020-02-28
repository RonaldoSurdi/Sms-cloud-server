json.array!(@plans) do |plan|
  json.extract! plan, :id, :descricao, :quantidade_sms

  json.tipo t(plan.tipo, scope: "tipo_plano")
  json.valor_total plan.valor_total.real_contabil
  json.valor_unitario plan.valor_unitario

  json.url plan_url(plan, format: :json)
  json.edit_html_url edit_plan_url(plan)
  json.show_html_url plan_url(plan)
end
