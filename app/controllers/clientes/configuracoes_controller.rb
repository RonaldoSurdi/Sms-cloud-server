class Clientes::ConfiguracoesController < Clientes::BaseController
  def update
    if current_customer.configuration.update(configuration_params)
      flash[:notice] = "Configurações atualizadas com sucesso."
      redirect_to painel_index_path
    else
      flash[:alert] = "Erro ao atualizar registro."
      render :index
    end
  end

  private

  def configuration_params
    params.require(:configuration).permit(:send_birthdays, :text_birthdays)
  end
end
