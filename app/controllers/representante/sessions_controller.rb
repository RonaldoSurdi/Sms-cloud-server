class Representante::SessionsController < Devise::SessionsController

  layout "representante"

  def after_sign_out_path_for(resource_or_scope)
    new_representative_session_path
  end
end