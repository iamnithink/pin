ActiveAdmin.register Sport do
  permit_params :name, :description, :icon, :display_order, :active

  index do
    selectable_column
    id_column
    column :name
    column :slug
    column :display_order
    column :active
    column :tournaments_count do |sport|
      sport.tournaments_count
    end
    actions
  end

  filter :name
  filter :active
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :icon
      f.input :display_order
      f.input :active
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :description
      row :icon
      row :display_order
      row :active
      row :tournaments_count do |sport|
        sport.tournaments_count
      end
      row :created_at
      row :updated_at
    end
  end

  # Use FriendlyId slugs in admin URLs
  controller do
    # Ensure FriendlyId slugs work and handle both id and slug
    def find_resource(param = nil)
      id_or_slug = param || params[:id]
      Sport.friendly.find(id_or_slug)
    end
  end
end

