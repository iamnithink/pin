class AddOrganizedByToTournaments < ActiveRecord::Migration[7.2]
  def change
    add_column :tournaments, :organized_by, :string, comment: "Organizer name (string field, not user association)"
  end
end
