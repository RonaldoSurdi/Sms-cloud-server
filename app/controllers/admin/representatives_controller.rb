class Admin::RepresentativesController < Admin::BaseController
  paginated_action only: [:index]

  before_action :set_representative, only: [:show, :update, :edit]
  before_action :verificar_aprovacao, only: [:edit, :destroy]
  before_action :filters, only: :index

  respond_to :html, :json

  def index
    @representatives = Representative
          .filter(@filter)
          .por_status(@status)
          .email_confirmado
          .order("#{@order} #{@asc_desc}")
          .page(@kp_page)

    respond_with(@representatives, layout: "index")
  end

  def show
    respond_with(@representative)
  end

  def edit
  end

  def update
    rep_params = representative_params

    if @recem_aprovado
      if @representative.update(rep_params)
        flash[:notice] =  "Cadastro aprovado! Um email foi enviado para #{@representative.email} avisando sobre a confirmação, junto com uma senha de acesso."

        RepresentativesMailer.cadastro_aceito(@representative, @senha_temporaria).deliver
      end
    else
      @representative.mensagem = rep_params[:mensagem]
      destroy
    end

    respond_with(@representative)
  end

  def destroy
    if @representative.destroy
      flash[:notice] =  "Cadastro excluído com sucesso! Um e-mail foi enviado para #{@representative.email} com o motivo da rejeição."

      RepresentativesMailer.cadastro_rejeitado(@representative).deliver
    end
  end

  private
    def set_representative
      @representative = Representative.email_confirmado.find(params[:id])
    end

    def representative_params
      @recem_aprovado = !@representative.cadastro_aprovado && params[:representative][:cadastro_aprovado] == "1"

      if @recem_aprovado
        @senha_temporaria = Devise.friendly_token.first(8)
        params[:representative][:password] = @senha_temporaria
        params[:representative][:password_confirmation] = @senha_temporaria

        params.require(:representative).permit(:cadastro_aprovado, :password, :password_confirmation)
      else
        params.require(:representative).permit(:mensagem)
      end
    end

    def filters
    @order ||= "nome_fantasia"

    if params[:clear] == "true"
      clear_controller_config
    else
      @filter = params[:filter] || get_controller_config(:filter)
      @status = params[:status] || get_controller_config(:status)
      store_controller_config(:filter, @filter)
      store_controller_config(:status, @status)
    end
  end

  def verificar_aprovacao
    if @representative.cadastro_aprovado
      flash[:alert] = "A página solicitada não pode ser acessada após o cadastro ter sido aprovado."
      redirect_to representatives_path
    end
  end
end
