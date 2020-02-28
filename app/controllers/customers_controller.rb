class CustomersController < ApplicationController
  def new
    our_representatives
    @customer = Customer.new(tipo_pessoa: :juridica)
    @customer.build_endereco
  end

  def create
    @customer = Customer.new(customer_params)

    @customer.representative_id = Representative.representante_principal.first.id if @customer.representative_id.blank?

    if @customer.save
      flash[:notice] = "Cadastro efetuado com sucesso! Visite seu e-mail para confirmar o cadastro, não se esqueça de olhar a caixa de SPAM."
      redirect_to new_public_customer_path
    else
      our_representatives
      render :new
    end
  end

  def self.controller_path
    "cadastro_clientes"
  end

  private

  def customer_params
    params.require(:customer).permit(:nome, :telefone, :celular, :email, :tipo_pessoa, :representative_id, :cpf_cnpj, :password,
          :password_confirmation, :razao_social, endereco_attributes: [ :id, :logradouro, :bairro, :cep, :complemento, :uf, :cidade ] )
  end

  def our_representatives
    @representatives = Representative.email_confirmado.aprovado.nao_representante_principal.select([:id, :nome_fantasia])
  end
end
