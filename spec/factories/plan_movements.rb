FactoryGirl.define do
  factory :plan_movement do

    plano_descricao { Faker::Lorem.words.join(" ").titleize }
    validade_inicio { Date.yesterday }
    validade_fim { Date.yesterday + PlanMovement.validade - 1.day }
    plano_valor_total { rand(1000) + 1 }
    quantidade_sms { rand(1000) + 1 }

    factory :plan_movement_avulso, traits: [:avulso, :com_customer]
    factory :plan_movement_adicional, traits: [:adicional, :com_customer]
    factory :plan_movement_licenca, traits: [:licenca, :com_license_movement]

    trait :avulso do
      plano_tipo { Plan.tipos[:avulso] }
    end

    trait :adicional do
      plano_tipo { Plan.tipos[:adicional] }
    end

    trait :licenca do
      plano_tipo { Plan.tipos[:licenca] }
      plano_descricao nil
    end

    trait :com_customer do
      association :customer, factory: :customer
    end

    trait :com_license_movement do
      association :license_movement, factory: :license_movement
    end

    trait :pagamento_confirmado do
      confirmado_pagamento_em { Date.today }
    end
  end
end
