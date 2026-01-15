class AddLikesCountToTournaments < ActiveRecord::Migration[7.2]
  def up
    add_column :tournaments, :likes_count, :integer, default: 0, null: false
    
    # Update existing tournaments with current like counts
    # Use SQL for better performance and to avoid model loading issues
    execute <<-SQL
      UPDATE tournaments
      SET likes_count = (
        SELECT COUNT(*)
        FROM tournament_likes
        WHERE tournament_likes.tournament_id = tournaments.id
      )
    SQL
  end

  def down
    remove_column :tournaments, :likes_count
  end
end
