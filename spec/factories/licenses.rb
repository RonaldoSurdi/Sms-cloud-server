FactoryGirl.define do
  factory :license, :class => 'License' do
    descricao { Faker::Lorem.words(3).join(" ").titleize }
    valor_unitario { ((rand(1000) + 1) + rand.round(2)).to_s.gsub(".", ",") }
    valor_sugerido { ((rand(1000) + 1) + rand.round(2)).to_s.gsub(".", ",") }
    tipo :nova
    association :plan, factory: :plan

    trait :nova do
      tipo :nova
    end

    trait :renovacao do
      tipo :renovacao
    end
  end
end