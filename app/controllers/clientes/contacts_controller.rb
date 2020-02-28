class Clientes::ContactsController < Clientes::BaseController

  before_action :set_contact, only: [:edit, :update, :destroy]
  before_action :set_contact_with_groups, only: [:show]
  before_action :set_contact_groups, only: [:new, :edit]
  skip_before_filter :verify_authenticity_token, only: [:create, :destroy]

  respond_to :html, :json

  def index
    @alphabet = ("A".."Z").to_a + [Customer::SYMBOL_FOR_NO_LETTER]
    @groups = current_customer.contact_groups.select([:id, :descricao]).order(:descricao)
    respond_to do |format|
      format.html
      format.json { render json: current_customer.contacts_with_groups_per_first_letter }
    end
  end

  def all
    render json: current_customer.contacts_with_groups
  end

  def show
    render json: [@contact, @contact.groups.collect(&:descricao)]
  end

  def new
    @contact = current_customer.contacts.build sexo: Contact.sexos[:masculino]
    respond_with @contact
  end

  def create
    @contact = current_customer.contacts.build(contact_params)
    if @contact.save
      render json: @contact
    else
      render json: @contact.errors, status: :bad_request
    end
  end

  def update
    if @contact.update(contact_params)
      flash[:notice] = "Registro atualizado com sucesso."
      redirect_to contacts_path
    else
      flash[:alert] = "Erro ao atualizar registro."
      render :edit
    end
  end

  def destroy
    render text: "Registro excluído com sucesso." if @contact.destroy
  end

  private

    def set_contact
      @contact = current_customer.contacts.find(params[:id])
    end

    def set_contact_with_groups
      @contact = current_customer.contacts.includes(:groups).find(params[:id])
    end

    def set_contact_groups
      @groups = current_customer.contact_groups.select([:id, :descricao]).order(:descricao)
    end

    def contact_params
      params[:contact][:group_ids] = [] if params[:contact][:group_ids].blank?
      params[:contact][:sexo] = params[:contact][:sexo].to_i

      params
        .require(:contact)
        .permit(:nome, :sexo, :celular, :email, :empresa, :nascimento, group_ids: [])
    end
end
