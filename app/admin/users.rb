ActiveAdmin.register User do
  permit_params :name, :email, :phone, :pincode, :address, :phone_verified, :latitude, :longitude

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :phone
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
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :phone
      f.input :pincode
      f.input :address
      f.input :phone_verified
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :email
      row :phone
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

