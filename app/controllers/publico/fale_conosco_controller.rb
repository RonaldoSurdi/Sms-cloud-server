class Publico::FaleConoscoController < ApplicationController
  def create
    if PublicMailer.fale_conosco_mensagem(info_contato_params).deliver
      flash[:notice] = "Mensagem enviada com sucesso! Vamos responder sua mensagem o mais breve possível no e-mail ou telefone informados."
      redirect_to fale_conosco_index_path
    else
      flash[:alert] = "Não foi possível enviar a sua mensagem. Por favor, tente mais tarde."
      redirect_to fale_conosco_index_path
    end
  end

  private

  def info_contato_params
    params.require(:contato).permit(:nome, :email, :telefone, :mensagem)
  end
end
