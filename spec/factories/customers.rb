FactoryGirl.define do
  factory :customer, class: 'Customer' do
    nome { Faker::Name.name }
    telefone { Faker::PhoneNumber.phone_number }
    celular { Faker::PhoneNumber.phone_number if rand(3) == 0 }
    sequence(:email) { |seq| "email_#{seq}@teste.com" }
    tipo_pessoa :fisica
    association :endereco, factory: :endereco
    association :representative, factory: :representative
    cpf_cnpj { BrFaker::Cpf.cpf }
    status :ok
    password "connect123"
    confirmed_at DateTime.current

    trait :pessoa_juridica do
      tipo_pessoa :juridica
      razao_social { Faker::Company.catch_phrase }
      cpf_cnpj { BrFaker::Cnpj.cnpj }
      nome { Faker::Company.name }
    end
  end

  trait :com_contatos do
    after :create do |customer|
      ActiveRecord::Base.transaction do
        10.times { FactoryGirl.create :contact, customer_id: customer.id }
      end
    end
  end
end
