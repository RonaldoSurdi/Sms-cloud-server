class RepresentantesController < ApplicationController
  def index
    redirect_to painel_opcoes_index_path if customer_signed_in?
  end
end
