json.array!(@contact_groups) do |contact_group|
  json.extract! contact_group, :id, :descricao, :observacao

  json.quantidade_contatos(contact_group.contacts.size)

  json.url contact_group_url(contact_group, format: :json)
  json.edit_html_url edit_contact_group_url(contact_group)
end
