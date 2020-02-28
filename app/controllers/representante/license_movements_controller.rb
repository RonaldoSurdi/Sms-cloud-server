class Representante::LicenseMovementsController < Representante::BaseController
  paginated_action only: [:index]

  before_action :set_license_movement, only: [:show, :destroy]
  before_action :filters, only: :index

  respond_to :html, :json

  def index
    @license_movements = LicenseMovement
                        .representative_filter(@filter)
                        .por_status(@status)
                        .por_representante(current_user)
                        .order("#{@order} #{@asc_desc}")
                        .page(@kp_page)

    respond_with(@license_movements, layout: "index")
  end

  def show
    respond_with(@license_movement)
  end

  def create
    @license_movement = LicenseMovement.new representative_id: current_user.id
    @movements_quantities = license_movement_params

    if license_movement_params.size != license_movement_params.values.grep("0").size
      if @license_movement.gerar(license_movement_params)
        flash[:notice] = "Compra efetuada com sucesso. Aguarde a confirmação de pagamento para uso da licenças adquiridas."
        RepresentativesMailer.notificacao_interesse_compra_licenca(current_user, @movements_quantities).deliver
      end
      respond_with(@license_movements, location: representative_license_movements_path(status: 'todas'))
    else
      flash[:alert] = "Você precisa selecionar pelo menos uma licença."
      render :new
    end
  end

  def destroy
    if !@license_movement.confirmada? && @license_movement.destroy
      flash[:notice] = "Registro excluído com sucesso"
      RepresentativesMailer.notificacao_exclusao_de_movimentacao_licenca(@license_movement).deliver
    end

    respond_with(@license_movement, location: representative_license_movements_path)
  end

  private
    def set_license_movement
      @license_movement = LicenseMovement.por_representante(current_user).find(params[:id])
    end

    def license_movement_params
      params.require(:license_movement)
    end

    def filters
      @order ||= "licenca_descricao"

      if params[:clear] == "true"
        clear_controller_config
      else
        @filter = params[:filter] || get_controller_config(:filter)
        @status = params[:status] || get_controller_config(:status)

        store_controller_config(:filter, @filter)
        store_controller_config(:status, @status)
      end
    end
end
