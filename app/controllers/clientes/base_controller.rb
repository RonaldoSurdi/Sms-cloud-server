class Clientes::BaseController < ApplicationController
  helper_method :current_user, :default_layout

  before_action :authenticate_customer!
  before_action :verificar_saldo

  def current_user
    current_customer
  end

  private

  def verificar_saldo
    unless current_customer.possui_saldo?
      flash[:alert] = "Você precisa de saldo de SMS's para acessar as funções do painel principal."
      redirect_to painel_opcoes_index_path
    end
  end
end