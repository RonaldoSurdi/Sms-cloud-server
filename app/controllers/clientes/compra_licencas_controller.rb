class Clientes::CompraLicencasController < Clientes::BaseController
  skip_before_action :verificar_saldo, only: [:index]

  def index
    @representative = current_customer.representative
  end
end