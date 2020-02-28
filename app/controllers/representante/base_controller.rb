class Representante::BaseController < ApplicationController
  helper_method :current_user, :default_layout

  layout "representante"

  before_action :authenticate_representative!
  before_action :set_order

  def current_user
    current_representative
  end

  private

  def default_layout
    "layouts/representante"
  end

end