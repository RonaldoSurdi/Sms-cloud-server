class CepController < ApplicationController
  def show
    @cep = Correios::CEP::AddressFinder.get(params[:id].to_s.gsub(/\D/, ''))

    if @cep.blank?
      @erro = "CEP não encontrado"
      @nao_encontrado = true
    end

  rescue => e
    Rails.logger.error e.inspect
    @erro = "A busca de endereço por CEP está indisponível, por favor, informe o nome de sua cidade."
  end
end
