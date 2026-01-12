class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
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
  end
end

