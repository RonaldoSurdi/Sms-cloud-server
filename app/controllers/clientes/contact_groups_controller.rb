class Clientes::ContactGroupsController < Clientes::BaseController

  before_action :set_contact_group, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, only: [:create, :destroy]

  respond_to :html, :json

  def index
    @contact_groups = current_customer.contact_groups.includes(:contacts)
    respond_with @contact_groups
  end

  def show
    respond_with @contact_group
  end

  def new
    respond_to do |format|
      format.html { @contact_group = current_customer.contact_groups.build }
    end
  end

  def create
    @contact_group = current_customer.contact_groups.build(contact_group_params)
    @contact_group.save
    render json: @contact_group
  end

  def update
    if @contact_group.update(contact_group_params)
      flash[:notice] = "Registro atualizado com sucesso."
      redirect_to contact_groups_path
    else
      flash[:alert] = "Erro ao atualizar registro."
      render :edit
    end
  end

  def destroy
    render text: "Registro excluído com sucesso." if @contact_group.destroy
  end

  def get_contacts
    render json: current_customer.contacts.order(:nome)
  end

  private

    def set_contact_group
      @contact_group = current_customer.contact_groups.find(params[:id])
    end

    def contact_group_params
      params[:contact_group][:contact_ids] = [] if params[:contact_group][:contact_ids].blank?

      params.require(:contact_group).permit(:descricao, :observacao, contact_ids: [])
    end
end
