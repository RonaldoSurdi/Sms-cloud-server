json.array!(@roles) do |role|
  json.extract! role, :id, :description
  json.url role_url(role, format: :json)
  json.edit_html_url edit_role_url(role)
  json.show_html_url role_url(role)
end
