FactoryGirl.define do
  factory :contact do
    nome { Faker::Name.name }
    celular { Faker::PhoneNumber.phone_number }
    sequence(:email) { |seq| "email#{seq}@teste.com.br" if rand(2) == 0 }
    empresa { Faker::Company.name if rand(5) == 0 }
    nascimento { Faker::Date.between(100.years.ago, Date.yesterday) if rand(5) == 0 }
    sexo { rand(2) }

    trait :com_grupo do
      after :build do |contact|
        contact.groups << FactoryGirl.build(:contact_group)
      end
    end

    trait :com_cliente do
      after :build do |contact|
        contact.customer = FactoryGirl.build(:customer)
      end
    end
  end
end
