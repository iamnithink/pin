class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :json

  # Skip authorization for signup (public action)
  skip_authorization_check

  protected

  def after_sign_up_path_for(resource)
    # New users go to ActiveAdmin Tournaments page
    admin_tournaments_path
  end

  def after_update_path_for(resource)
    root_path(locale: I18n.locale)
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :phone, :password, :password_confirmation, :pincode, :address)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :phone, :password, :password_confirmation, :current_password, :pincode, :address)
  end

  private

  def respond_with(resource, _opts = {})
    if request.format.json?
      if resource.persisted?
        render json: {
          success: true,
          user: {
            id: resource.id,
            name: resource.name,
            email: resource.email
          }
        }, status: :created
      else
        render json: {
          success: false,
          errors: resource.errors.full_messages
        }, status: :unprocessable_entity
      end
    else
      super
    end
  end
end

