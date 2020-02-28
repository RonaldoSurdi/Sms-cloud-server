class Ability
  include CanCan::Ability
  include Admin::RolesHelper

  def initialize(user)
    Rails.logger.debug "Defining abilities"
    user.roles.each do |role|
      Rails.logger.debug " Role #{role}"
      if role.full_control
        authorizable_models.each do |model|
          actions = authorizable_actions_of(model).collect(&:to_sym)
          can actions, model.constantize
          Rails.logger.debug "  can #{actions}, #{model.constantize}"
        end
      else
        role.permissions.each do |permission|
          actions = permission.actions.to_a.collect(&:to_sym)
          model   = permission.subject
          if authorizable_models.include?(model)
            can actions, model.constantize
            Rails.logger.debug "  can #{actions}, #{model.constantize}"
          else
            Rails.logger.debug " Model #{model} não faz parte de authorizable_models (#{authorizable_models})"
          end
        end
      end
    end
    Rails.logger.debug "Abilities defined"
  end
end
