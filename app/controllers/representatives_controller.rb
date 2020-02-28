class RepresentativesController < ApplicationController

  def new
    @representante = Representative.new
    @representante.build_endereco
  end

  def create
    senha = Devise.friendly_token

    @representante = Representative.new(representante_params)
    @representante.assign_attributes(password: senha, password_confirmation: senha)
    if @representante.save
      flash[:notice] = "Cadastro efetuado com sucesso! Visite seu e-mail para confirmar o cadastro, não se esqueça de olhar a caixa de SPAM."
      redirect_to new_public_representative_path
    else
      render :new
    end
  end

  def por_estado
    representantes = Representative
                      .select([:nome_fantasia, :email, :telefone])
                      .joins(:endereco)
                      .por_uf(params["uf"])
                      .aprovado

    render json: representantes
  end

  def self.controller_path
    "cadastro_representantes"
  end

  private

  def representante_params
    params.require(:representative).permit(:razao_social, :nome_fantasia, :cnpj, :inscricao_estadual, :responsavel, :telefone, :celular, :email, :logo,
                                endereco_attributes: [ :id, :logradouro, :bairro, :cep, :complemento, :uf, :cidade ] )
  end
end
