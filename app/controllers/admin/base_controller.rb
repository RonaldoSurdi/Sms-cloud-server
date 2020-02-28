class Admin::BaseController < ApplicationController
  helper_method :current_user, :default_layout

  layout "admin"

  before_action :authenticate_administrator!
  before_action :set_order

  authorize_resource except: [:multiple_confirm, :multiple_destroy]

  def current_user
    current_administrator
  end

  private

  def default_layout
    "layouts/admin"
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to administrator_root_url, alert: 'Você não tem permissão para acessar o recurso solicitado'
  end
end
