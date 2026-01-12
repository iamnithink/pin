ActiveAdmin.register CricketMatchType do
  permit_params :name, :team_size, :category, :sub_category, :description, :active

  index do
    selectable_column
    id_column
    column :name
    column :team_size
    column :category
    column :sub_category
    column :active
    column :tournaments_count do |type|
      type.tournaments_count
    end
    actions
  end

  filter :name
  filter :team_size
  filter :category
  filter :sub_category
  filter :active

  form do |f|
    f.inputs do
      f.input :name
      f.input :team_size
      f.input :category, as: :select, collection: %w[full_ground supersix]
      f.input :sub_category, as: :select, collection: %w[overarm_bowling underarm_bowling legspin_action_only all_action_bowling], include_blank: true
      f.input :description
      f.input :active
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :team_size
      row :category
      row :sub_category
      row :description
      row :active
      row :tournaments_count do |type|
        type.tournaments_count
      end
      row :created_at
      row :updated_at
    end
  end

  # Use FriendlyId slugs in admin URLs
  controller do
    def find_resource(param = nil)
      id_or_slug = param || params[:id]
      CricketMatchType.friendly.find(id_or_slug)
    end
  end
end

