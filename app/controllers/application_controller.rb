class ApplicationController < ActionController::API
  include SessionManipulator
  include ::ActionController::Cookies

  rescue_from CanCan::AccessDenied do |exception|
    exception.default_message = 'You are not authorized'
    render json: { error: exception.message }, status: :forbidden
  end

  def current_ability
    model_name = controller_name.classify
    @current_ability ||= "Abilities::#{model_name}Ability".constantize.new(current_user)
  end
end
