class Admin::PlansController < Admin::BaseController
  paginated_action only: [:index]

  before_action :set_plan, only: [:show, :edit, :update, :destroy]
  before_action :filters, only: :index

  respond_to :html, :json

  def index
    @plans = Plan
          .filter(@filter)
          .order("#{@order} #{@asc_desc}")
          .page(@kp_page)

    respond_with(@plans, layout: "index")
  end

  def show
    respond_with(@plan)
  end

  def new
    @plan = Plan.new tipo: :licenca, quantidade_sms: 0, valor_total: 0
    respond_with(@plan)
  end

  def edit
  end

  def create
    @plan = Plan.new(plan_params)
    flash[:notice] = "Registro criado com sucesso" if @plan.save
    respond_with(@plan)
  end

  def update
    flash[:notice] =  "Dados alterados com sucesso" if @plan.update(plan_params)
    respond_with(@plan)
  end

  def destroy
    if @plan.licenses.any?
      flash[:alert] = "O plano não pode ser excluído se estiver associado a uma licença. Para excluir esse plano é preciso que você troque o plano das licenças associadas ou que exclua as licenças associadas."
    else
      flash[:notice] =  "Registro excuído com sucesso" if @plan.destroy
    end

    respond_with(@plan)
  end

  private

  def set_plan
    @plan = Plan.find(params[:id])
  end

  def plan_params
    params.require(:plan).permit(:tipo, :quantidade_sms, :valor_total, :descricao)
  end

  def filters
    @order ||= "descricao"
    @order = "(valor_total / quantidade_sms)" if @order == "valor_unitario"

    if params[:clear] == "true"
      clear_controller_config
    else
      @filter = params[:filter] || get_controller_config(:filter)
      store_controller_config(:filter, @filter)
    end
  end
end
