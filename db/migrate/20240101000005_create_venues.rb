class CreateVenues < ActiveRecord::Migration[7.2]
  def change
    create_table :venues do |t|
      t.string :name, null: false
      t.text :description
      t.string :address, null: false
      t.string :pincode, null: false
      t.string :city
      t.string :state
      t.string :country, default: 'India'
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.string :google_maps_link
      t.string :contact_phone
      t.string :contact_email
      t.decimal :hourly_rate
      t.boolean :is_verified, default: false
      t.boolean :is_active, default: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.timestamps null: false
    end

    add_index :venues, :pincode
    add_index :venues, [:latitude, :longitude]
    add_index :venues, :is_verified
    add_index :venues, :is_active
  end
end

