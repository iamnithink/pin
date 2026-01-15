# Make authenticate_admin_user! available to ActiveAdmin controllers
# ActiveAdmin controllers don't inherit from ApplicationController,
# so we need to define the method in ActiveAdmin::BaseController
Rails.application.config.to_prepare do
  ActiveAdmin::BaseController.class_eval do
    # Include Devise helpers to access user_signed_in? and current_user
    include Devise::Controllers::Helpers
    
    # Override authenticate_admin_user! to allow all authenticated users
    # This method is called by ActiveAdmin before any action
    def authenticate_admin_user!
      # Check if user is signed in - try multiple methods for reliability
      signed_in = false
      
      # Method 1: Check user_signed_in? helper (most reliable)
      if respond_to?(:user_signed_in?, true)
        begin
          signed_in = user_signed_in?
        rescue
          signed_in = false
        end
      end
      
      # Method 2: Check current_user (set by ActiveAdmin via config.current_user_method)
      unless signed_in
        if respond_to?(:current_user, true)
          begin
            signed_in = current_user.present?
          rescue
            signed_in = false
          end
        end
      end
      
      # Method 3: Check session directly (fallback)
      unless signed_in
        user_id = session.dig('warden.user.user.key')&.first&.first
        signed_in = user_id.present?
      end
      
      # If not signed in, redirect to sign in page
      unless signed_in
        session[:return_to] = request.fullpath if request.get?
        redirect_to new_user_session_path(locale: I18n.locale), alert: 'Please sign in to access this page.'
        return
      end
      
      # User is signed in - allow access
      # Individual resources control access via menu 'if' conditions
    end
  end
end

ActiveAdmin.setup do |config|
  config.site_title = "PIN Admin"
  
  # Use User model with role-based authentication
  # Allow all authenticated users to access ActiveAdmin
  # Individual resources control access via menu 'if' conditions
  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_user
  config.logout_link_path = '/users/sign_out'
  
  config.batch_actions = true
  config.localize_format = :long
  config.comments = false

  # Custom footer text
  config.footer = "All rights reserved © 2026 PIN(PlayInNear)"
  
  # Register Trix JavaScript for rich text editing
  config.register_javascript 'trix'

  # Arctic Admin - Responsive meta tags for mobile support
  config.meta_tags = { viewport: "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" }
  config.meta_tags_for_logged_out_pages = { viewport: "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" }
end
