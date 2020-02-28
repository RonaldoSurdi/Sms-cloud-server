json.array!(@customers) do |customer|
  json.extract! customer, :id, :cpf_cnpj, :nome, :telefone, :email

  json.cpf_cnpj_formatado(customer.cpf_cnpj_formatado)
  json.telefone_formatado(customer.telefone_formatado)

  json.representatives(nome_fantasia: customer.representative.nome_fantasia)

=begin (função de bloquear ainda não está sendo usada)
  if customer.ok?
    json.status({ classes: "icon-ok text-success", title: "Situação do cadastro OK" })
  elsif customer.bloqueado?
    json.status({ classes: "icon-lock text-warning", title: "Usuário Bloqueado" })
  end
=end

  json.url customer_url(customer, format: :json)
  json.show_html_url customer_url(customer)
end
