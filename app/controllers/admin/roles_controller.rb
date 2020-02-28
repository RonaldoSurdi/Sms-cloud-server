class Admin::RolesController < Admin::BaseController
  include Admin::RolesHelper
  paginated_action only: [:index]

  before_action :set_role, only: [:show, :edit, :update, :destroy]
  before_action :filters, only: :index

  respond_to :html, :json

  def index
    @order ||= "description"
    @roles = Role
      .filter(@filter)
      .order("#{@order} #{@asc_desc}")
      .page(@kp_page)

    respond_with(@roles, layout: "index")
  end

  def show
    respond_with(@role)
  end

  def new
    @role = Role.new
    populate_permissions
    respond_with(@role)
  end

  def edit
    if @role.full_control
      redirect_to @role, alert: "Esta permissão não pode ser editada."
    else
      populate_permissions
    end
  end

  def create
    @role = Role.new(role_params)
    normalize_actions!

    @role.save

    respond_with(@role)
  end

  def update
    if @role.full_control
      respond_to @role, alert: "Não é possível editar essa permissão."
    else
      normalize_actions!
      if @role.update(role_params)
        flash[:notice] = "Permisão foi alterada com sucesso"
      else
        flash[:alert] = "Falha ao editar permissão."
      end
      respond_with(@role)
    end
  end

  def destroy
    if @role.destroy
      flash[:notice] = "Registro excluído com sucesso."
    else
      flash[:alert] = "Esta permissão não pode ser excluída."
    end
    respond_with(@role)
  end

  private

    def set_role
      @role = Role.find(params[:id])
    end

    def role_params
      params.require(:role).permit(:description, permissions_attributes: [:id, :subject, actions: []])
    end

    def populate_permissions
      unless @role.new_record?
        @role.permissions.each do |permission|
          permission.destroy unless authorizable_models.include?(permission.subject)
        end
        @role.permissions.reload
      end

      authorizable_models.each do |subject|
        unless @role.permissions.collect(&:subject).include?(subject.to_s)
          @role.permissions.build(subject: subject.to_s)
        end
      end
    end

    def normalize_actions!
      @role.permissions.each do |permission|
        permission.actions.reject! do |action|
          !authorizable_actions_of(Role).include?(action)
        end
      end
    end

    def filters
    @order ||= "description"

    if params[:clear] == "true"
      clear_controller_config
    else
      @filter = params[:filter] || get_controller_config(:filter)
      store_controller_config(:filter, @filter)
    end
  end
end
