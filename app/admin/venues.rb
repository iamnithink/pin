ActiveAdmin.register Venue do
  includes :created_by
  permit_params :name, :description, :address, :pincode, :city, :state, :country,
                :latitude, :longitude, :google_maps_link, :contact_phone, :contact_email,
                :hourly_rate, :is_verified, :is_active, :created_by_id

  index do
    selectable_column
    id_column
    column :name
    column :address
    column :pincode
    column :is_verified
    column :is_active
    column :created_by
    column :tournaments_count do |venue|
      venue.tournaments_count
    end
    actions
  end

  filter :name
  filter :pincode
  filter :city
  filter :is_verified
  filter :is_active
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :address
      f.input :pincode
      f.input :city
      f.input :state
      f.input :country, as: :string, hint: "Enter country name (e.g., India, USA)"
      f.input :latitude
      f.input :longitude
      f.input :google_maps_link
      f.input :contact_phone
      f.input :contact_email
      f.input :hourly_rate
      f.input :created_by
      f.input :is_verified
      f.input :is_active
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :address
      row :pincode
      row :city
      row :state
      row :country
      row :latitude
      row :longitude
      row :google_maps_link do |venue|
        link_to venue.google_maps_url, venue.google_maps_url, target: '_blank' if venue.google_maps_url.present?
      end
      row :contact_phone
      row :contact_email
      row :hourly_rate
      row :is_verified
      row :is_active
      row :created_by
      row :created_at
      row :updated_at
    end
  end
end

