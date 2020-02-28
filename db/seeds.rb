if Role.count.zero?
  Role.create!(description: 'Controle Total', full_control: true)

  Role.create!(description: 'Somente Leitura').tap do |role|
    puts "Role #{role.description} criada com permissao apenas de leitura"
    include Admin::RolesHelper
    authorizable_models.each do |model|
      role.permissions.create!(subject: model, actions: ["read"])
    end
  end
elsif Role.where(full_control: true).count.zero?
  roles = Role.where(description: 'Controle Total')
  if roles.blank?
    Role.create!(description: 'Controle Total', full_control: true)
  else
    roles.first.update!(full_control: true)
  end
end

if Administrator.count.zero?
  puts "Inserindo administrador principal"
  adm = Administrator.create! email: "teste@teste.com.br", password: "connect123", name: "Administrador Teste", main_administrator: true
  adm.role_ids = Role.where(full_control: true).collect(&:id)
elsif Administrator.where(main_administrator: true).count.zero?
  adm = Administrator.first
  puts "Inserindo controle total ao administrador \'#{adm}\'"
  adm.update! main_administrator: true
  unless adm.roles.find_by(full_control: true)
    adm.roles = Role.where(full_control: true)
  end
end

#ALTERAR DEPOIS PARA AS REAIS INFORMAÇÕES DA ronaldosurdi
if Representative.representante_principal.count.zero?
  puts "Inserindo representante principal 'ronaldosurdi'"

  Representative.create! nome_fantasia: "ronaldosurdi", razao_social: "ronaldosurdi", cnpj: "11.660.655/0560-86", responsavel: "ronaldosurdi", telefone: "(54) 9999-9999",
                          email: EMAIL_ronaldosurdi, password: "connect123", password_confirmation: "connect123", confirmed_at: Date.today,
                          cadastro_aprovado: true, representante_principal: true,
                          endereco_attributes: {logradouro: "Rua Qualquer Coisa, 99", bairro: "Centro", cidade: "Erechim", uf: "RS", cep: "99700-000"}
end