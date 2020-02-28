class AdministratorsMailer < BaseMailer

  TITULOS = {
    exclusao_unica: "Notificação de exclusão de interesse em compra",
    exclusao_multipla: "Notificação de exclusão de interesses em compra",
    confirmacao_unica: "Notificação de confirmação de pagamento",
    confirmacao_multipla: "Notificação de confirmações de pagamento"
  }

  def notificacao_exclusao_de_movimentacao_licenca(license_movement)
    @license_movement = license_movement
    @representative = @license_movement.representative
    mail subject: TITULOS[:exclusao_unica], to: @representative.email
  end

  def compra_licenca_do_representante_confirmada(license_movement)
    @license_movement = license_movement
    mail subject: TITULOS[:confirmacao_unica], to: @license_movement.representative.email
  end

  def notificacao_exclusao_multipla_de_movimentacao_licenca(representative, license_movements)
    @representative = representative
    @license_movements = license_movements

    mail subject: TITULOS[:exclusao_multipla], to: @representative.email
  end

  def multiplas_compras_de_licencas_confirmadas(representative, license_movements)
    @representative = representative
    @license_movements = license_movements

    mail subject: TITULOS[:confirmacao_multipla], to: @representative.email
  end


  def notificacao_exclusao_de_movimentacao_plano(plan_movement)
    @plan_movement = plan_movement
    mail subject: TITULOS[:exclusao_unica], to: @plan_movement.customer.email
  end

  def compra_plano_do_cliente_confirmada(plan_movement)
    @plan_movement = plan_movement
    mail subject: TITULOS[:confirmacao_unica], to: @plan_movement.customer.email
  end

  def notificacao_exclusao_multipla_de_movimentacao_plano(plan_movements)
    @customer = plan_movements.first.customer
    @plan_movements = plan_movements

    mail subject: TITULOS[:exclusao_multipla], to: @customer.email
  end

  def multiplas_compras_de_planos_confirmadas(plan_movements)
    @customer = plan_movements.first.customer
    @plan_movements = plan_movements

    mail subject: TITULOS[:confirmacao_multipla], to: @customer.email
  end
end
