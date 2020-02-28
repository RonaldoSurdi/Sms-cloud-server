module Admin::RolesHelper

  def authorizable_models
    %w(Administrator Role Representative Customer Plan License LicenseMovement OurCustomer PlanMovement)
  end

  def authorizable_actions
    %w(read create update destroy)
  end

  def authorizable_actions_of(_model)
    model = _model.try(:constantize) ? _model.constantize : _model

    limited_actions = %w{read update destroy}
    limited_models = %w{Representative Customer LicenseMovement PlanMovement}

    models_with_limited_actions = limited_models.collect { |model| [model, limited_actions] }

    limited_actions_to_model = models_with_limited_actions.select { |const, value| const.constantize == model }.try(:first)

    if limited_actions_to_model.present?
      limited_actions_to_model[1] #[1] = ARRAY DE ACTIONS, [0] = MODEL
    else
      authorizable_actions
    end
  end

end
