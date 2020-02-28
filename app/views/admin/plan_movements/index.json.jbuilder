json.array!(@plan_movements) do |plan_movement|
  json.extract! plan_movement, :id, :plano_descricao, :quantidade_sms

  json.cliente_nome plan_movement.customer.nome
  json.created_at plan_movement.created_at.to_s_br
  json.plano_valor_total plan_movement.plano_valor_total.real_contabil
  json.plano_tipo t(plan_movement.plano_tipo, scope: "tipo_plano")

  if params[:status] == 'aguardando'
    if (can?(:update, PlanMovement) || can?(:destroy, PlanMovement))
      json.status(title: 'Compra aguardando confirmação')
    end
  else
    if plan_movement.confirmada?
      json.status(icon: 'icon-check text-success', title: 'Compra confirmada')
    else
      json.status(icon: 'icon-refresh text-warning', title: 'Compra aguardando confirmação')
    end
  end

  json.url plan_movement_url(plan_movement, format: :json)
  json.show_html_url plan_movement_url(plan_movement)
end
