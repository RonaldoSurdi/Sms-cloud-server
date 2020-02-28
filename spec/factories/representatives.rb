FactoryGirl.define do

  factory :representative do
    razao_social { Faker::Company.catch_phrase }
    nome_fantasia { Faker::Company.name }
    cnpj { BrFaker::Cnpj.cnpj }
    inscricao_estadual { (rand(2) == 0) ? Faker::Company.ein : nil }
    responsavel { Faker::Name.name }
    telefone { Faker::PhoneNumber.phone_number }
    celular { Faker::PhoneNumber.phone_number if rand(3) == 0 }
    sequence(:email)  { |seq| "email#{seq}@teste.com.br" }
    association :endereco, factory: :endereco
    password "connect123"
    confirmed_at DateTime.current
  end

end
