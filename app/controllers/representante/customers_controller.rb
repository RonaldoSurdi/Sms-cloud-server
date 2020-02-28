class Representante::CustomersController < Representante::BaseController
  paginated_action only: [:index]

  before_action :filters, only: :index
  before_action :set_customer, only: :verify_customer

  respond_to :html, :json

  def index
    @customers = current_user.customers
        .includes(:license_movements)
        .representatives_filter(@filter)
        .email_confirmado
        .nao_eliminado
        .por_status_venda(@status_venda)
        .order("#{@order} #{@asc_desc}")
        .page(@kp_page)

    respond_with(@customers, layout: "index")
  end

  def show
    @customer = current_user.customers
                  .includes(:license_movements)
                  .email_confirmado
                  .nao_eliminado
                  .order("license_movements.data_venda_cliente DESC")
                  .find(params[:id])

    @current_license_id = @customer.current_license_movement.try(:id)

    respond_with(@customer)
  end

  def sale
    @customers = current_user.customers
                  .pode_comprar_licenca
                  .email_confirmado
                  .nao_eliminado
                  .status_ok
  end

  def verify_customer
    new_customer = @customer.license_movements.empty?

    @license_movements = LicenseMovement
      .unicas
      .por_representante(current_user.id)
      .confirmadas
      .nao_vendidas

    if new_customer
      @license_movements = @license_movements.where(licenca_tipo: License.tipos[:nova])
    else
      @license_movements = @license_movements.where(licenca_tipo: License.tipos[:renovacao])
    end
  end

  def sell
    license_movement = LicenseMovement.por_representante(current_user.id).confirmadas.nao_vendidas.where(license_id: sale_params[:license_id].to_i).first
    customer = current_user.customers.pode_comprar_licenca.email_confirmado.status_ok.find(sale_params[:customer_id].to_i)

    if license_movement.present? && customer.present?
      ActiveRecord::Base.transaction do
        license_movement.valor_venda_cliente = sale_params[:valor_venda_cliente]
        license_movement.vender_para_cliente(customer)
        PlanMovement.gerar_movimentos_de_planos_para_a_licenca(license_movement)
      end

      RepresentativesMailer.notificacao_para_cliente_de_licenca_adquirida(license_movement, customer, current_user).deliver
      flash[:notice] = "Licença vendida com sucesso!"

      redirect_to action: :index
    else
      flash[:alert] = "Não foi possível efetuar a venda!"
      redirect_to action: :sale
    end
  end

  private

    def sale_params
      params.require(:sale).permit(:customer_id, :license_id, :valor_venda_cliente)
    end

    def filters
    @order ||= "nome"

    if params[:clear] == "true"
      clear_controller_config
    else
      @filter = params[:filter] || get_controller_config(:filter)
      @status_venda = params[:status_venda] || get_controller_config(:status_venda)
      store_controller_config(:filter, @filter)
      store_controller_config(:status_venda, @status_venda)
    end
  end

  def set_customer
    @customer = current_user.customers
                  .pode_comprar_licenca
                  .email_confirmado
                  .nao_eliminado
                  .find(params[:id])
  end
end
