class Admin::LicenseMovementsController < Admin::BaseController
  paginated_action only: [:index]

  before_action :set_license_movement, only: [:show, :update, :destroy]
  before_action :set_multiple_license_movements, only: [:multiple_confirm, :multiple_destroy]
  before_action :filters, only: :index

  respond_to :html, :json

  def index
    @license_movements = LicenseMovement
                        .filter(@filter)
                        .por_status(@status)
                        .joins(:representative)
                        .includes(:representative)
                        .order("#{@order} #{@asc_desc}")
                        .page(@kp_page)

    respond_with(@license_movements, layout: "index")
  end

  def show
    respond_with(@license_movement)
  end

  def update
    if !@license_movement.confirmada? && @license_movement.confirmar
      flash[:notice] = "Compra confirmada com sucesso!"
      AdministratorsMailer.compra_licenca_do_representante_confirmada(@license_movement).deliver
    end
    respond_with(@license_movement)
  end

  def destroy
    if !@license_movement.confirmada? && @license_movement.destroy
      flash[:notice] = "Registro excluído com sucesso. Um E-Mail foi enviado ao representante avisando sobre a exclusão do pedido."
      AdministratorsMailer.notificacao_exclusao_de_movimentacao_licenca(@license_movement).deliver
    end

    respond_with(@license_movement)
  end

  def multiple_confirm
    authorize! :update, LicenseMovement

    if LicenseMovement.confirm_sales(@license_movements)
      flash[:notice] = "Compras confirmadas com sucesso!"


      representatives = Representative.where(id: @license_movements.collect(&:representative_id).uniq)

      representatives.each do |representative|
        license_movements = @license_movements.select { |license_movement| license_movement.representative_id == representative.id }

        AdministratorsMailer.multiplas_compras_de_licencas_confirmadas(representative, license_movements).deliver
      end
    end

    redirect_to license_movements_path
  end

  def multiple_destroy
    authorize! :destroy, LicenseMovement

    if LicenseMovement.destroy_sales(@license_movements)
      flash[:notice] = "Registros excluídos com sucesso."


      representatives = Representative.where(id: @license_movements.collect(&:representative_id).uniq)

      representatives.each do |representative|
        license_movements = @license_movements.select { |license_movement| license_movement.representative_id == representative.id }
        AdministratorsMailer.notificacao_exclusao_multipla_de_movimentacao_licenca(representative, license_movements).deliver
      end
    end

    redirect_to license_movements_path
  end

  private
    def set_license_movement
      @license_movement = LicenseMovement.find(params[:id])
    end

    def set_multiple_license_movements
      @license_movements = LicenseMovement
                          .nao_confirmadas
                          .where(id: params[:checked_records].collect(&:to_i))
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
