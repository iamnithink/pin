ActiveAdmin.register User do
  permit_params :name, :email, :phone, :pincode, :address, :phone_verified, 
                :latitude, :longitude, :role, :password, :password_confirmation

  menu priority: 2, label: "Users", if: proc { current_user&.admin? || current_user&.super_admin? }

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :phone
    column :role do |user|
      status_tag user.role, class: user.role
    end
    column :phone_verified
    column :pincode
    column :created_at
    actions
  end

  filter :name
  filter :email
  filter :phone
  filter :pincode
  filter :phone_verified
  filter :role, as: :select, collection: User.roles.keys.map { |r| [r.humanize, r] }
  filter :created_at

  scope :all, default: true
  scope :super_admins
  scope :admins
  scope :users

  form do |f|
    f.inputs "User Information" do
      f.input :name
      f.input :email
      f.input :phone
      f.input :pincode
      f.input :address
      f.input :phone_verified
    end

    f.inputs "Authentication" do
      f.input :password, hint: "Leave blank if you don't want to change it"
      f.input :password_confirmation
    end

    f.inputs "Role & Permissions" do
      if current_user&.super_admin?
        f.input :role, as: :select, collection: User.roles.keys.map { |r| [r.humanize, r] },
                hint: "super_admin: Full access | admin: Dashboard, Teams, Tournaments, Venues | user: Own dashboard and tournaments"
      else
        f.input :role, as: :string, input_html: { disabled: true, value: (f.object.role || 'user').humanize },
                hint: "Only super_admin can change roles. Current: #{f.object.role || 'user'}"
        f.input :role, as: :hidden, input_html: { value: f.object.role || 'user' }
      end
    end

    f.actions
  end

  controller do
    skip_authorization_check
    
    # Block regular users from accessing this resource
    before_action :restrict_regular_users!
    
    def update
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
      
      # Only super_admin can change roles
      unless current_user&.super_admin?
        params[:user].delete(:role)
      end
      
      super
    end

    def create
      # Set default role to 'user' if not specified
      params[:user][:role] ||= 'user' if params[:user].present?
      
      # Only super_admin can assign admin/super_admin roles
      unless current_user&.super_admin?
        if params[:user][:role].present? && ['admin', 'super_admin'].include?(params[:user][:role])
          params[:user][:role] = 'user'
        end
      end
      
      super
    end
    
    private
    
    def restrict_regular_users!
      if current_user.present? && current_user.regular_user?
        redirect_to admin_root_path, alert: 'You do not have permission to access this page.'
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :name
      row :email
      row :phone
      row :role do |user|
        status_tag user.role, class: user.role
      end
      row :phone_verified
      row :pincode
      row :address
      row :latitude
      row :longitude
      row :created_at
      row :updated_at
    end

    panel "Tournaments Created" do
      tournaments = user.created_tournaments.includes(:sport)
      table_for tournaments do
        column :title
        column :sport
        column :tournament_status
        column :start_time
        column :actions do |tournament|
          link_to "View", admin_tournament_path(tournament)
        end
      end
    end
  end
end

