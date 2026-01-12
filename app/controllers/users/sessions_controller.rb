class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: {
      success: true,
      user: {
        id: resource.id,
        name: resource.name,
        email: resource.email
      }
    }
  end

  def respond_to_on_destroy
    render json: { success: true, message: 'Logged out successfully' }
  end
end

