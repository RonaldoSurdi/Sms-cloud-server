class PagseguroService
  EMAIL = "financeiro@sendmy.net"
  TOKEN = "D08B098F082A4FFF9875B223D3DC51D0"
  ENVIRONMENT = :production

  def self.create!(pacote)
    PagseguroService.initialize_values

    payment = PagSeguro::PaymentRequest.new email: EMAIL, token: TOKEN
    payment.sender = {
      name: pacote.customer.nome,
      email: pacote.customer.email,
      phone: {
        area_code: pacote.customer.telefone[0..1],
        number: pacote.customer.telefone[2..-1]
      }
    }

    payment.sender.cpf = pacote.customer.cpf_cnpj if pacote.customer.fisica?
    payment.reference = pacote.id

    payment.items << {
      id: pacote.id,
      description: pacote.plano_descricao,
      amount: pacote.plano_valor_total.to_f
    }

    payment.shipping = {
      type_name: "not_specified",
      address: {
        street: pacote.customer.endereco.logradouro,
        number: 0,
        complement: pacote.customer.endereco.complemento,
        district: pacote.customer.endereco.bairro,
        city: pacote.customer.endereco.cidade,
        state: pacote.customer.endereco.uf,
        postal_code: pacote.customer.endereco.cep
      }
    }

    response = payment.register
    if response.errors.any?
      Rails.logger.error '==== PAGSEGURO ERROR (PagseguroService.create!) ===='
      Rails.logger.error response.errors.join("; ")
    end
    response
  end

  def self.find_by_code(code)
    PagseguroService.initialize_values
    PagSeguro::Transaction.find_by_code(code)
  end

  private

  def self.initialize_values
    PagSeguro.environment = ENVIRONMENT
    PagSeguro.email = EMAIL
    PagSeguro.token = TOKEN
  end
end
