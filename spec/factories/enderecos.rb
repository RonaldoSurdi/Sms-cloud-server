FactoryGirl.define do
  factory :endereco do
    logradouro { Faker::Address.street_address }
    bairro { Faker::Lorem.word.titlecase }
    cidade { Faker::Address.city }
    uf { Faker::Address.state_abbr }
    cep { Faker::Address.postcode }
    complemento { ["", Faker::Address.secondary_address, ""][rand(3)] }
  end
end
