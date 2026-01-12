class AddContactPhonesAndTeamsTextToTournaments < ActiveRecord::Migration[7.2]
  def change
    add_column :tournaments, :contact_phones, :text, comment: "JSON array of contact phone numbers"
    add_column :tournaments, :teams_text, :text, comment: "Text field for team names (one per line)"
  end
end
