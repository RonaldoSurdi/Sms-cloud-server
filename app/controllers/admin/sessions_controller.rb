class Admin::SessionsController < Devise::SessionsController

  layout "admin"

  def after_sign_out_path_for(resource_or_scope)
    new_administrator_session_path
  end
end