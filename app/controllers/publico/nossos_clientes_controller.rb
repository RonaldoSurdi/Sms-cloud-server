class Publico::NossosClientesController < ApplicationController
  def index
    @our_customers = OurCustomer
      .order(created_at: :desc)
      .page(params[:page])
      .per(20)
  end
end
