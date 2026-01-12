class Api::V1::UsersController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:send_otp, :verify_otp]

  def show
    user = User.find(params[:id])
    render_success(serialize_user(user))
  end

  def update
    if current_user.update(user_params)
      render_success(serialize_user(current_user))
    else
      render_error(current_user.errors.full_messages.join(', '))
    end
  end

  def send_otp
    phone = params[:phone]
    return render_error('Phone number is required') unless phone.present?

    user = User.find_or_initialize_by(phone: phone)
    user.name ||= params[:name] || 'User'
    user.save(validate: false)

    otp = user.generate_otp
    # In production, send OTP via SMS service (Twilio, etc.)
    # SendOtpJob.perform_later(user.phone, otp)
    
    render_success({ message: 'OTP sent successfully', otp: Rails.env.development? ? otp : nil })
  end

  def verify_otp
    phone = params[:phone]
    otp = params[:otp]
    
    return render_error('Phone and OTP are required') unless phone.present? && otp.present?

    user = User.find_by(phone: phone)
    return render_error('User not found') unless user.present?

    if user.verify_otp(otp)
      sign_in(user)
      render_success({ user: serialize_user(user), token: 'your_jwt_token_here' })
    else
      render_error('Invalid or expired OTP')
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :phone, :pincode, :address, :avatar_url)
  end

  def serialize_user(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      phone_verified: user.phone_verified,
      pincode: user.pincode,
      address: user.address,
      avatar_url: user.avatar_url
    }
  end
end

