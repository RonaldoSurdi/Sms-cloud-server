class Representante::ProfileController < Representante::BaseController

  before_action :set_representative, only: [:edit, :update]

  respond_to :html, :json

  def update
    params_dup = representative_params
    params_dup.except!(:password, :password_confirmation, :current_password) if representative_params[:password].blank?

    flash[:notice] =  "Dados alterados com sucesso" if @representative.update(params_dup)
    respond_with(@representative, location: representative_root_path)
  end

  private

  def set_representative
    @representative = current_user
  end

  def representative_params
    params
      .require(:representative)
      .permit(:nome_fantasia, :razao_social, :inscricao_estadual, :email, :responsavel, :telefone, :celular, :logo, :current_password, :password, :password_confirmation,
          endereco_attributes: [ :id, :logradouro, :bairro, :cep, :complemento, :uf, :cidade ])
      .merge(valid_current_password: true)
  end
end