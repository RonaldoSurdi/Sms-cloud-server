json.array!(@customers) do |customer|
  json.extract! customer, :id, :nome, :cpf_cnpj, :telefone, :email

  json.cpf_cnpj_formatado(customer.cpf_cnpj_formatado)
  json.telefone_formatado(customer.telefone_formatado)

  json.license_movement(licenca_descricao: customer.current_license_movement.try(:licenca_descricao),
              validade_fim: customer.current_license_movement.try(:validade_fim).try(:to_s_br))

=begin Função de bloquear não está sendo usada ainda
  if customer.ok?
    json.status({ classes: "icon-ok text-success", title: "Situação do cadastro OK" })
  elsif customer.bloqueado?
    json.status({ classes: "icon-lock text-warning", title: "Usuário Bloqueado" })
  end
=end

  json.url representative_customer_url(customer, format: :json)
  json.show_html_url representative_customer_url(customer)
end
