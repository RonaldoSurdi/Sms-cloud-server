json.array!(@license_movements) do |license_movement|
  json.extract! license_movement, :license_id, :licenca_descricao, :plano_descricao, :plano_quantidade_sms, :quantidade

  json.licenca_valor_sugerido(license_movement.licenca_valor_sugerido.reais_contabeis)
end