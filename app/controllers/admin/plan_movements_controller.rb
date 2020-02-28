class Admin::PlanMovementsController < Admin::BaseController
  paginated_action only: [:index]

  before_action :set_plan_movement, only: [:show, :update, :destroy]
  before_action :set_multiple_plan_movements, only: [:multiple_confirm, :multiple_destroy]
  before_action :filters, only: :index

  respond_to :html, :json

  def index
    @plan_movements = PlanMovement
                        .joins(:customer)
                        .includes(:customer)
                        .avulso_ou_adicional
                        .por_status(@status)
                        .filter(@filter)
                        .order("#{@order} #{@asc_desc}")
                        .page(@kp_page)

    respond_with(@plan_movements, layout: "index")
  end

  def show
    respond_with(@plan_movement)
  end

  def update
    if !@plan_movement.confirmada? && @plan_movement.confirmar
      flash[:notice] = "Compra confirmada com sucesso!"
      AdministratorsMailer.compra_plano_do_cliente_confirmada(@plan_movement).deliver
    end

    respond_with(@plan_movement)
  end

  def destroy
    if !@plan_movement.confirmada? && @plan_movement.destroy
      flash[:notice] = "Registro excluído com sucesso. Um E-Mail foi encaminhado ao cliente avisando sobre a exclusão do pedido."
      AdministratorsMailer.notificacao_exclusao_de_movimentacao_plano(@plan_movement).deliver
    end

    respond_with(@plan_movement)
  end

  def multiple_confirm
    authorize! :update, PlanMovement

    plans_per_customer = @plan_movements.inject({}) do |result, plan_movement|
      result[plan_movement.customer_id] ||= []
      result[plan_movement.customer_id] << plan_movement
      result
    end

    if PlanMovement.confirmar_todos(@plan_movements) > 0
      flash[:notice] = "Compras confirmadas com sucesso!"

      plans_per_customer.each do |customer_id, plan_movements|
        AdministratorsMailer
            .multiplas_compras_de_planos_confirmadas(plan_movements)
            .deliver
      end
    end

    redirect_to plan_movements_path
  end

  def multiple_destroy
    authorize! :destroy, PlanMovement

    plans_per_customer = @plan_movements.inject({}) do |result, plan_movement|
      result[plan_movement.customer_id] ||= []
      result[plan_movement.customer_id] << plan_movement
      result
    end

    if @plan_movements.delete_all > 0
      flash[:notice] = "Registros excluídos com sucesso. Um E-Mail foi encaminhado aos clientes avisando sobre a exclusão do pedido."

      plans_per_customer.each do |customer_id, plan_movements|
        AdministratorsMailer
            .notificacao_exclusao_multipla_de_movimentacao_plano(plan_movements)
            .deliver
      end
    end

    redirect_to plan_movements_path
  end

  private
    def set_plan_movement
      @plan_movement = PlanMovement
                        .avulso_ou_adicional
                        .find(params[:id])
    end

    def set_multiple_plan_movements
      @plan_movements = PlanMovement
                          .joins(:customer)
                          .includes(:customer)
                          .avulso_ou_adicional
                          .nao_confirmadas
                          .where(id: params[:checked_records].collect(&:to_i))
    end

    def filters
      @order ||= "plano_descricao"

      if params[:clear].try(:to_bool)
        clear_controller_config
      else
        @filter = params[:filter] || get_controller_config(:filter)
        @status = params[:status] || get_controller_config(:status)

        store_controller_config(:filter, @filter)
        store_controller_config(:status, @status)
      end
    end
end
