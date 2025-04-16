class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :house_id])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :house_id])
  end

  helper_method :current_house

  private

  def current_house
    @current_house ||= House.find_by(id: session[:current_house_id])
  end

  def set_current_house
    if params[:house_id]
      session[:current_house_id] = params[:house_id]
    else
      session[:current_house_id] ||= (
        @house&.id || current_user.houses.first&.id
      )
    end
  end
end
