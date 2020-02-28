json.array!(@our_customers) do |our_customer|
  json.extract! our_customer, :id, :descricao

  json.cliente_url(our_customer.url)

  json.url our_customer_url(our_customer, format: :json)
  json.edit_html_url edit_our_customer_url(our_customer)
  json.show_html_url our_customer_url(our_customer)
end
