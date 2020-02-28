FactoryGirl.define do
  factory :administrator do
    name { Faker::Name.name }
    sequence(:email) { |seq| "adm_email#{seq}@teste.com.br" }
    password "connect123"
  end
end
