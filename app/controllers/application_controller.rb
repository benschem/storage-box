# frozen_string_literal: true

# Base controller
class ApplicationController < ActionController::Base
  include ActionView::RecordIdentifier # Needed to use dom_id
  include Pagy::Backend
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name house_id])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name house_id])
  end

  after_action :verify_pundit_authorization, unless: :skip_pundit?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def verify_pundit_authorization
    action_name == 'index' ? verify_policy_scoped : verify_authorized
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.' # rubocop:disable Rails/I18nLocaleTexts
    redirect_back_or_to(root_path)
  end
end
