class Admin::OurCustomersController < Admin::BaseController
  paginated_action only: [:index]

  before_action :set_our_customer, only: [:show, :edit, :update, :destroy]
  before_action :filters, only: [:index]

  respond_to :html, :json

  def index
    @our_customers = OurCustomer
          .filter(@filter)
          .order("#{@order} #{@asc_desc}")
          .page(@kp_page)

    respond_with @our_customers, layout: "index"
  end

  def show
    respond_with @our_customer
  end

  def new
    @our_customer = OurCustomer.new
    respond_with @our_customer
  end

  def create
    @our_customer = OurCustomer.new(our_customer_params)
    flash[:notice] = "Registro criado com sucesso." if @our_customer.save
    respond_with @our_customer
  end

  def update
    flash[:notice] = "Registro atualizado com sucesso." if @our_customer.update(our_customer_params)
    respond_with @our_customer
  end

  def destroy
    flash[:notice] = "Registro excluído com sucesso." if @our_customer.destroy
    respond_with @our_customer
  end

  private

    def set_our_customer
      @our_customer = OurCustomer.find(params[:id])
    end

    def our_customer_params
      params.require(:our_customer).permit(:descricao, :url, :logo)
    end

    def filters
      @order ||= "descricao"

      if params[:clear] == "true"
        clear_controller_config
      else
        @filter = params[:filter] || get_controller_config(:filter)
        store_controller_config(:filter, @filter)
      end
    end
end
