class AddVenueFieldsToTournaments < ActiveRecord::Migration[7.2]
  def change
    add_column :tournaments, :venue_name, :string
    add_column :tournaments, :venue_address, :text
    add_column :tournaments, :venue_latitude, :decimal, precision: 10, scale: 7
    add_column :tournaments, :venue_longitude, :decimal, precision: 10, scale: 7
    add_column :tournaments, :venue_google_maps_link, :string
    
    # Make venue_id optional since we're moving to Google Maps
    change_column_null :tournaments, :venue_id, true
  end
end
