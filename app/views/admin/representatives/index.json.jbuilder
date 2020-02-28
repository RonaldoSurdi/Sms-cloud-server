json.array!(@representatives) do |representative|
  json.extract! representative, :id, :razao_social, :nome_fantasia, :cnpj, :responsavel, :telefone, :email

  json.cnpj_formatado(representative.cnpj_formatado)
  json.telefone_formatado(representative.telefone_formatado)

  if representative.cadastro_aprovado
    json.cadastro_aprovado({ classes: "icon-flag text-success", title: "Cadastro aprovado" })
  else
    json.cadastro_aprovado({ classes: "icon-flag-alt text-warning", title: "Cadastro aguardando aprovação" })
  end

  json.url representative_url(representative, format: :json)
  json.show_html_url representative_url(representative)
end
