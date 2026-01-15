class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  # CanCanCan authorization (skip for ActiveAdmin - it has its own auth)
  check_authorization unless: -> { devise_controller? || active_admin_controller? }
  
  def active_admin_controller?
    # ActiveAdmin controllers are namespaced as Admin::*Controller
    return true if self.class.name.start_with?('Admin::')
    # Or check if it's an ActiveAdmin base controller
    return false unless defined?(ActiveAdmin::BaseController)
    self.class.ancestors.include?(ActiveAdmin::BaseController)
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_path(locale: I18n.locale), alert: exception.message }
      format.json { render json: { success: false, message: exception.message }, status: :forbidden }
    end
  end

  # ActiveAdmin authentication - allow all authenticated users
  # Individual resources control access via menu 'if' conditions
  # This method is called by ActiveAdmin via config.authentication_method
  def authenticate_admin_user!
    # Check if user is signed in using Devise helper
    # This works better than current_user.present? in ActiveAdmin context
    unless user_signed_in?
      session[:return_to] = request.fullpath if request.get?
      redirect_to new_user_session_path(locale: I18n.locale), alert: 'Please sign in to access this page.'
    end
  end

  protected

  def set_locale
    # Extract locale from params (set by route scope) or default to English
    # When locale is nil in params, it means we're using the default locale (en)
    # since the route scope makes locale optional
    I18n.locale = params[:locale]&.to_sym || I18n.default_locale
    session[:locale] = I18n.locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone, :pincode, :address])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone, :pincode, :address, :avatar_url])
  end
end
