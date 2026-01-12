class PopulateCounterCaches < ActiveRecord::Migration[7.2]
  def up
    # Reset counter caches using SQL (more reliable in migrations)
    execute <<-SQL
      UPDATE sports
      SET tournaments_count = (
        SELECT COUNT(*)
        FROM tournaments
        WHERE tournaments.sport_id = sports.id
      )
    SQL

    execute <<-SQL
      UPDATE cricket_match_types
      SET tournaments_count = (
        SELECT COUNT(*)
        FROM tournaments
        WHERE tournaments.cricket_match_type_id = cricket_match_types.id
      )
    SQL

    execute <<-SQL
      UPDATE venues
      SET tournaments_count = (
        SELECT COUNT(*)
        FROM tournaments
        WHERE tournaments.venue_id = venues.id
      )
    SQL
  end

  def down
    # No need to reverse this
  end
end
