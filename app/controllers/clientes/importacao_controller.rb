class Clientes::ImportacaoController < Clientes::BaseController
  before_action :set_separador, only: [:create]
  before_action :set_codificacoes

  def create
    options = {
      col_sep: @separador,
      encoding: @codificacoes[params[:tipo_codificacao].to_i]
    }

    erros = Contact.gerar_por_string_csv(params[:arquivo].read, current_customer, options)

    if erros.blank?
      redirect_to painel_index_path, notice: "Importação de contatos realizada com sucesso!"
    else
      @erros = erros
      render :new
    end
  end

  private

  def set_separador
    if params[:tipo_arquivo].to_i == Contact::SEPARADORES_CSV[:tab][:valor]
      @separador = Contact::SEPARADORES_CSV[:tab][:separador]
    elsif params[:tipo_arquivo].to_i == Contact::SEPARADORES_CSV[:ponto_e_virgula][:valor]
      @separador = Contact::SEPARADORES_CSV[:ponto_e_virgula][:separador]
    else
      @separador = Contact::SEPARADORES_CSV[:virgula][:separador]
    end
  end

  def set_codificacoes
    @codificacoes = [
      Encoding::ISO_8859_1,
      Encoding::UTF_8
    ]
  end
end
