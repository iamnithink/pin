class Users::SessionsController < Devise::SessionsController
  respond_to :html, :json

  # Skip authorization for signin (public action)
  skip_authorization_check

  protected

  def after_sign_in_path_for(resource)
    if resource.admin? || resource.super_admin?
      admin_root_path
    else
      # Regular users go to ActiveAdmin Tournaments page
      admin_tournaments_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path(locale: I18n.locale)
  end

  private

  def respond_with(resource, _opts = {})
    if request.format.json?
      render json: {
        success: true,
        user: {
          id: resource.id,
          name: resource.name,
          email: resource.email
        }
      }
    else
      super
    end
  end

  def respond_to_on_destroy
    if request.format.json?
      render json: { success: true, message: 'Logged out successfully' }
    else
      redirect_to after_sign_out_path_for(resource_name), notice: 'Signed out successfully.'
    end
  end
end

