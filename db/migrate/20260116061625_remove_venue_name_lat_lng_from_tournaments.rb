class RemoveVenueNameLatLngFromTournaments < ActiveRecord::Migration[7.2]
  def change
    remove_column :tournaments, :venue_name, :string
    remove_column :tournaments, :venue_latitude, :decimal, precision: 10, scale: 7
    remove_column :tournaments, :venue_longitude, :decimal, precision: 10, scale: 7
  end
end
