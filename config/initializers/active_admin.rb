ActiveAdmin.setup do |config|
  config.site_title = "PIN Admin"
  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_admin_user
  config.logout_link_path = :destroy_admin_user_session_path
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
  
  # Navigation customization
  config.namespace :admin do |admin|
    admin.build_menu :utility_navigation do |menu|
      menu.add label: proc { display_name current_admin_user }, 
               url: '#', 
               id: 'current_user',
               html_options: { class: 'current_user' }
      admin.add_logout_button_to_menu menu
    end
  end
end

