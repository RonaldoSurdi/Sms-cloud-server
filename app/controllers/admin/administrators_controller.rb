class Admin::AdministratorsController < Admin::BaseController
  paginated_action only: [:index]

  before_action :set_administrator, only: [:show, :edit, :update, :destroy]
  before_action :filters, only: :index

  respond_to :html, :json

  def index
    @administrators = Administrator
          .filter(@filter)
          .order("#{@order} #{@asc_desc}")
          .page(@kp_page)

    respond_with(@administrators, layout: "index")
  end

  def show
    respond_with(@administrator)
  end

  def new
    @administrator = Administrator.new
    respond_with(@administrator)
  end

  def edit
  end

  def create
    @administrator = Administrator.new(administrator_params)
    flash[:notice] = "Registro criado com sucesso" if @administrator.save
    respond_with(@administrator)
  end

  def update
    params_dup = administrator_params
    params_dup.except!(:password, :password_confirmation) if params_dup[:password].blank?

    flash[:notice] =  "Dados alterados com sucesso" if @administrator.update(params_dup)
    respond_with(@administrator)
  end

  def destroy
    if @administrator.destroy
      flash[:notice] = "Registro excluído com sucesso."
    else
      flash[:alert] = "Este administrador não pode ser excluído."
    end
    respond_with(@administrator)
  end

  private

  def set_administrator
    @administrator = Administrator.find(params[:id])
  end

  def administrator_params
    params.require(:administrator).permit(:name, :email, :password, :password_confirmation, role_ids: [])
  end

  def filters
    @order ||= "name"

    if params[:clear] == "true"
      clear_controller_config
    else
      @filter = params[:filter] || get_controller_config(:filter)
      store_controller_config(:filter, @filter)
    end
  end
end
