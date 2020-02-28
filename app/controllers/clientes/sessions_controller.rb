class Clientes::SessionsController < Devise::SessionsController

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def after_sign_in_path_for(resource)
    painel_opcoes_index_url
  end
end