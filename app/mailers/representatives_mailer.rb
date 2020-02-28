class RepresentativesMailer < BaseMailer

  def cadastro_aceito(representative, senha_temporaria)
    @representative = representative
    @senha_temporaria = senha_temporaria
    mail subject: "Aprovação de cadastro na ronaldosurdi", to: @representative.email
  end

  def cadastro_rejeitado(representative)
    @representative = representative
    mail subject: "Rejeição de cadastro na ronaldosurdi", to: @representative.email
  end

  def cliente_cadastrado(customer)
    @customer = customer
    mail subject: "ronaldosurdi - Um cliente escolheu você como representante", to: @customer.representative.email
  end

  def notificacao_interesse_compra_licenca(representative, movements_quantities)
    @representative = representative
    @movements_quantities = movements_quantities.select { |k,v| v.to_i > 0 }
    @licenses = License.where(id: @movements_quantities.keys.collect(&:to_i)).order("descricao asc")

    mail subject: "Notificação de interesse em compra", to: EMAIL_ronaldosurdi
  end

  def notificacao_exclusao_de_movimentacao_licenca(license_movement)
    @license_movement = license_movement
    @representative = @license_movement.representative
    mail subject: "Notificação de negação de interesse em compra", to: EMAIL_ronaldosurdi
  end

  def notificacao_para_cliente_de_licenca_adquirida(license_movement, customer, representative)
    @license_movement = license_movement
    @customer = customer
    @representative = representative

    mail subject: "Notificação de compra de licença", to: @customer.email
  end
end
