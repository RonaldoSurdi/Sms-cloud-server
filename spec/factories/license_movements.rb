FactoryGirl.define do
  factory :license_movement do
    association :license, factory: :license
    association :representative, factory: :representative

    plano_descricao { "#{license.plan.descricao}" }
    plano_quantidade_sms { "#{license.plan.quantidade_sms}" }
    plano_valor_total { "#{license.plan.valor_total}" }
    licenca_descricao { "#{license.descricao}" }
    licenca_tipo { "#{license.tipo}" }
    licenca_valor_unitario { "#{license.valor_unitario}" }
    licenca_valor_sugerido { "#{license.valor_sugerido}" }
    valor_venda_cliente { ((rand(1000) + 1) + rand.round(2)).to_s.gsub(".", ",") }

    factory :sold_license_movement, traits: [:vendida, :atual]
    factory :confirmed_license_movement, traits: [:confirmada]

    trait :atual do
      data_venda_cliente Date.today
      validade_inicio Date.today
      validade_fim Date.today + LicenseMovement.validade
    end

    trait :reserva do
      data_venda_cliente Date.today + 1.day
      validade_inicio Date.today + 1.day
      validade_fim Date.today + LicenseMovement.validade + 1.day
    end

    trait :vencendo do
      data_venda_cliente 10.months.ago
      validade_inicio 10.months.ago
      validade_fim 10.months.ago + LicenseMovement.validade
    end

    trait :vencida do
      data_venda_cliente Date.today - LicenseMovement.validade - 1.day
      validade_inicio Date.today - LicenseMovement.validade - 1.day
      validade_fim Date.today - 1.day
    end

    trait :vencida_a_muito_tempo do
      data_venda_cliente 2.years.ago - LicenseMovement.validade
      validade_inicio 2.years.ago - LicenseMovement.validade
      validade_fim 2.years.ago + LicenseMovement.validade
    end

    trait :confirmada do
      confirmado_pagamento_em DateTime.current
    end

    trait :vendida do
      confirmada
      association :customer, factory: :customer
    end

    trait :com_movimentacao_de_planos do
      after(:create) { |license_movement| PlanMovement.gerar_movimentos_de_planos_para_a_licenca(license_movement) }
    end

    trait :com_licenca_reserva do
      after(:create) do |license_movement|
        create(:sold_license_movement,
            data_venda_cliente: Date.today,
            validade_inicio: license_movement.validade_fim + 1.day,
            validade_fim: (license_movement.validade_fim + 1.day) + LicenseMovement.validade,
            customer: license_movement.customer,
            representative: license_movement.representative)
      end
    end
  end
end
