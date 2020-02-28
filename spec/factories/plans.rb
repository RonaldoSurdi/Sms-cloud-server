FactoryGirl.define do
  factory :plan, :class => 'Plan' do
    tipo :licenca
    quantidade_sms { (rand(1000) + 1) }
    valor_total { ((rand(1000) + 1) + rand.round(2)).to_s.gsub(".", ",") }
    descricao { Faker::Lorem.words(3).join(" ").titleize }

    trait :licenca do
      tipo :licenca
    end

    trait :adicional do
      tipo :adicional
    end

    trait :avulso do
      tipo :avulso
    end
  end
end
