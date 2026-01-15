ActiveAdmin.register_page "Home" do
  # Show Home menu for all authenticated users - redirects to public homepage
  menu priority: 0, label: "Home", if: proc { current_user.present? }

  controller do
    skip_authorization_check
    
    def index
      redirect_to root_path(locale: I18n.locale)
    end
  end
end
