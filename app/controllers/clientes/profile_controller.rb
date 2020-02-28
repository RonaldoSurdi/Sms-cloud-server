class Clientes::ProfileController < Clientes::BaseController

  skip_before_action :verificar_saldo
  before_action :set_customer, only: [:edit, :update]

  respond_to :html, :json

  def update
    params_dup = customer_params
    params_dup.except!(:password, :password_confirmation, :current_password) if customer_params[:password].blank?

    flash[:notice] =  "Dados alterados com sucesso" if @customer.update(params_dup)
    respond_with(@customer, location: painel_index_path)
  end

  private

  def set_customer
    @customer = current_user
  end

  def customer_params
    params
      .require(:customer)
      .permit(:nome, :razao_social, :email, :telefone, :celular, :current_password, :password, :password_confirmation,
          endereco_attributes: [ :id, :logradouro, :bairro, :cep, :complemento, :uf, :cidade ])
      .merge(valid_current_password: true)
  end
end