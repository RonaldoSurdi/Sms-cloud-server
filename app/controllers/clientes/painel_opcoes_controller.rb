class Clientes::PainelOpcoesController < Clientes::BaseController
  skip_before_action :verificar_saldo

  def index
    @customer = current_customer
  end
end
