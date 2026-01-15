ActiveAdmin.register_page "My Profile" do
  # Show profile menu for all authenticated users
  menu priority: 10, label: "My Profile", if: proc { current_user.present? }

  controller do
    skip_authorization_check

    def index
      @user = current_user
    end

    def update
      @user = current_user
      
      # Prepare update params
      update_params = profile_params
      
      # Remove password fields if blank
      if update_params[:password].blank?
        update_params.delete(:password)
        update_params.delete(:password_confirmation)
      end
      
      # Regular users can't change their email or role
      update_params.delete(:email)
      update_params.delete(:role)
      
      if @user.update(update_params)
        redirect_to admin_my_profile_path, notice: 'Profile updated successfully.'
      else
        flash[:error] = @user.errors.full_messages.join(', ')
        redirect_to admin_my_profile_path
      end
    end

    private

    def profile_params
      params.require(:user).permit(:name, :phone, :pincode, :address, :password, :password_confirmation)
    end
  end

  content title: "My Profile" do
    panel "Profile Information" do
      attributes_table_for current_user do
        row :name
        row :email
        row :phone
        row :pincode
        row :address
        row :role do |user|
          status_tag user.role, class: user.role
        end
        row :phone_verified do |user|
          user.phone_verified? ? status_tag("Verified", class: "ok") : status_tag("Not Verified", class: "no")
        end
        row :created_at
        row :updated_at
      end
    end

    panel "Edit Profile" do
      active_admin_form_for current_user, url: "/admin/my_profile", method: :patch do |f|
        f.inputs "Personal Information" do
          f.input :name
          f.input :phone, input_html: { pattern: "[0-9]{10}", maxlength: "10" }
          f.input :pincode, hint: "6 digits (e.g., 560001)", input_html: { pattern: "[0-9]{6}", maxlength: "6" }
          f.input :address, as: :text, input_html: { rows: 3 }
        end

        f.inputs "Change Password (Optional)" do
          f.input :password, hint: "Leave blank if you don't want to change it"
          f.input :password_confirmation
        end

        f.actions do
          f.action :submit, label: "Update Profile"
        end
      end
    end

    para do
      link_to "Go to Public Homepage", root_path(locale: I18n.locale), class: "button", target: "_blank"
    end
  end
end
