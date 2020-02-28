class ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message(:notice, (resource_class == Representative) ? :representative_confirmed : :confirmed) if is_flashing_format?
      send_customer_confirmated_email_to_representative if resource_class == Customer
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
  end

  protected

  def after_confirmation_path_for(resource_name, resource)
    if resource_class == Representative
      send "new_public_#{resource_class.name.underscore}_path"
    elsif resource_class == Customer
      new_customer_session_path
    end
  end

  def after_resending_confirmation_instructions_path_for(resource_name)
    send "new_#{resource_class.name.underscore}_confirmation_path"
  end

  def send_customer_confirmated_email_to_representative
    RepresentativesMailer.cliente_cadastrado(resource).deliver
  end
end