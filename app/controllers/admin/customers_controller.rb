class Admin::CustomersController < Admin::BaseController
  paginated_action only: [:index]

  before_action :set_customer, only: [:update, :destroy]
  before_action :filters, only: :index

  respond_to :html, :json

  def index
    @customers = Customer
        .filter(@filter)
        .email_confirmado
        .nao_eliminado
        .eager_load(:representative)
        .order("#{@order} #{@asc_desc}")
        .page(@kp_page)

    respond_with(@customers, layout: "index")
  end

  def show
    @customer = Customer
                  .includes(:license_movements, :representative)
                  .references(:all)
                  .email_confirmado
                  .nao_eliminado
                  .order("license_movements.data_venda_cliente DESC")
                  .find(params[:id])

    @plan_movements = PlanMovement
                        .confirmadas
                        .avulso_ou_adicional
                        .where(customer_id: @customer.id)

    @current_license_id = @customer.current_license_movement.try(:id)

    respond_with(@customer)
  end

  def update
    if (params[:customer][:status] == "ok" || params[:customer][:status] == "bloqueado")
      if @customer.update params.require(:customer).permit(:status)
        if @customer.bloqueado?
          params[:notice] = "Cliente bloqueado com sucesso!"
        else
          params[:notice] = "Cliente desbloqueado com sucesso!"
        end
      end
    end

    respond_with(@customer)
  end

  #POR ENQUANTO NÃO ESTÁ SENDO USADO
  def destroy
    @customer.destroy
    respond_with(@customer)
  end

  private
    def set_customer
      @customer = Customer.email_confirmado.nao_eliminado.find(params[:id])
    end

    def filters
    @order ||= "nome"

    if params[:clear] == "true"
      clear_controller_config
    else
      @filter = params[:filter] || get_controller_config(:filter)
      store_controller_config(:filter, @filter)
    end
  end
end
