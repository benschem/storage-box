class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :household_id])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :household_id])
  end

  helper_method :current_household

  private

  def current_household
    @current_household ||= Household.find_by(id: session[:current_household_id])
  end

  def set_current_household
    if params[:household_id]
      session[:current_household_id] = params[:household_id]
    else
      session[:current_household_id] ||= (
        @household&.id || current_user.households.first&.id
      )
    end
  end
end
