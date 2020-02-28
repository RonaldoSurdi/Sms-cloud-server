class Admin::LicensesController < Admin::BaseController
  paginated_action only: [:index]

  before_action :set_license, only: [:show, :edit, :update, :destroy]
  before_action :filters, only: :index

  respond_to :html, :json

  def index
    @licenses = License
          .filter(@filter)
          .por_tipo(@tipo)
          .eager_load(:plan)
          .order("#{@order} #{@asc_desc}")
          .page(@kp_page)

    respond_with(@licenses, layout: "index")
  end

  def show
    respond_with(@license)
  end

  def new
    @license = License.new tipo: :nova, valor_unitario: 0, valor_sugerido: 0
    respond_with(@license)
  end

  def create
    @license = License.new(license_params)
    flash[:notice] = "Registro criado com sucesso" if @license.save
    respond_with(@license)
  end

  def update
    flash[:notice] = "Dados alterados com sucesso" if @license.update(license_params)
    respond_with(@license)
  end

  def destroy
    flash[:notice] = "Registro excluído com sucesso" if @license.destroy
    respond_with(@license)
  end

  private
    def set_license
      @license = License.find(params[:id])
    end

    def license_params
      params.require(:license).permit(:descricao, :valor_unitario, :valor_sugerido, :tipo, :plan_id)
    end

    def filters
      @order ||= "licenses.descricao"

      if params[:clear] == "true"
        clear_controller_config
      else
        @filter = params[:filter] || get_controller_config(:filter)
        @tipo = params[:tipo] || get_controller_config(:tipo)
        store_controller_config(:filter, @filter)
        store_controller_config(:tipo, @tipo)
      end
    end
end
