class Admin::ProfileController < Admin::BaseController

  before_action :set_administrator, only: [:edit, :update]

  respond_to :html, :json

  skip_load_and_authorize_resource

  def update
    params_dup = administrator_params
    params_dup.except!(:password, :password_confirmation, :current_password) if administrator_params[:password].blank?

    flash[:notice] =  "Dados alterados com sucesso" if @administrator.update(params_dup)
    respond_with(@administrator, location: administrator_root_path)
  end

  private

  def set_administrator
    @administrator = current_user
  end

  def administrator_params
    params
      .require(:administrator)
      .permit(:name, :email, :current_password, :password, :password_confirmation, role_ids: [])
      .merge(valid_current_password: true)
  end
end