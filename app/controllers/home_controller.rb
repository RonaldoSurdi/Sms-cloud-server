class HomeController < Clientes::BaseController
  skip_before_action :authenticate_customer!, only: [:index]
  skip_before_action :verificar_saldo

  def index
    @our_customers = OurCustomer.randomic(4)
  end
end
