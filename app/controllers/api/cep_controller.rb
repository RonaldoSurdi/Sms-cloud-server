class Api::CepController < ApplicationController
  def show
    cep_number = params[:id].gsub(/\D/, "").insert(-4, "-")
    @cep = BuscaEndereco.cep(cep_number)
  rescue => e
    @cep = {}
    if e.message.to_s.include?("não encontrado")
      @error = "CEP não encontrado"
    else
      @error = "A busca de endereço por CEP está indisponível, por favor, informe manualmente os dados de endereço."
    end
  ensure
    if @error
      render json: { message: @error }, status: :bad_request
    else
      render json: @cep
    end
  end
end
