class AddPrizesToTournaments < ActiveRecord::Migration[7.2]
  def change
    add_column :tournaments, :first_prize, :decimal, precision: 10, scale: 2
    add_column :tournaments, :second_prize, :decimal, precision: 10, scale: 2
    add_column :tournaments, :third_prize, :decimal, precision: 10, scale: 2
    add_column :tournaments, :prizes_json, :text, comment: "JSON field for additional prize levels"
  end
end
