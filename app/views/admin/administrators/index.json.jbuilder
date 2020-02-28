json.array!(@administrators) do |administrator|
  json.extract! administrator, :id, :name, :email
  json.url administrator_url(administrator, format: :json)
  json.edit_html_url edit_administrator_url(administrator)
  json.show_html_url administrator_url(administrator)
  json.last_sign_in_at_fmt administrator.last_sign_in_at.to_s_br
end
