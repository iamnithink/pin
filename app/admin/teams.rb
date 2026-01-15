ActiveAdmin.register Team do
  includes :sport, :captain
  permit_params :name, :description, :sport_id, :captain_id, :is_active, :is_default

  menu priority: 3, label: "Teams", if: proc { current_user&.admin? || current_user&.super_admin? }

  index do
    selectable_column
    id_column
    column :name
    column :sport
    column :captain
    column :member_count
    column :is_default do |team|
      team.is_default? ? "Yes (Admin)" : "No (User)"
    end
    column :is_active
    actions
  end

  filter :name
  filter :sport
  filter :captain
  filter :is_active
  filter :is_default
  filter :created_at

  scope :all
  scope :default_teams
  scope :user_teams

  form do |f|
    f.inputs do
      f.input :name
      f.input :sport
      f.input :captain
      f.input :is_default, hint: "Check this for default teams created by Admin"
      f.input :is_active
    end

    f.inputs "Description" do
      f.input :description, as: :rich_text_area
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :sport
      row :captain
      row :member_count
      row :is_default do |team|
        team.is_default? ? "Yes (Admin)" : "No (User)"
      end
      row :is_active
      row :created_at
      row :updated_at
    end

    panel "Description" do
      div do
        team.description if team.description.present?
      end
    end
  end

  # Use FriendlyId slugs in admin URLs
  controller do
    skip_authorization_check
    
    # Block regular users from accessing this resource
    before_action :restrict_regular_users!
    
    def find_resource(param = nil)
      id_or_slug = param || params[:id]
      Team.friendly.find(id_or_slug)
    end
    
    private
    
    def restrict_regular_users!
      if current_user.present? && current_user.regular_user?
        redirect_to admin_root_path, alert: 'You do not have permission to access this page.'
      end
    end
  end
end

