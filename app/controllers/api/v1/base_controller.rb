class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_default_format

  private

  def set_default_format
    request.format = :json
  end

  def render_success(data = {}, status = :ok)
    render json: { success: true, data: data }, status: status
  end

  def render_error(message, status = :unprocessable_entity)
    render json: { success: false, error: message }, status: status
  end
end

