class Clientes::CompraPacotesController < Clientes::BaseController
  before_action :set_plan, only: [:create]
  skip_before_action :verificar_saldo

  def index
    if current_customer.possui_licenca_atual?
      @plans = Plan.adicional
    else
      @plans = Plan.avulso
    end
  end

  def show
    plan_movement_id = PagseguroService.find_by_code(params[:id]).items.first.id
    render json: current_customer.plan_movements.find(plan_movement_id)
  end

  def create
    plan_movement = PlanMovement.criar_pacote_sms(@plan, current_customer)
    pagseguro = nil
    pagseguro = PagseguroService.create!(plan_movement) if plan_movement.persisted?

    if pagseguro && pagseguro.errors.blank?
      pagseguro = PagseguroService.create!(plan_movement)
      redirect_to pagseguro.url
    else
      flash[:alert] = "Ops, não foi possível efetuar a transação no momento. Por favor, tente mais tarde."
      redirect_to painel_opcoes_index_path
    end
  end

  private

  def set_plan
    if current_customer.possui_licenca_atual?
      @plan = Plan.adicional.find(params[:plan_id])
    else
      @plan = Plan.avulso.find(params[:plan_id])
    end
  end
end
