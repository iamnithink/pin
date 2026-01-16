class AddCommentsCountToTournaments < ActiveRecord::Migration[7.2]
  def change
    add_column :tournaments, :comments_count, :integer, default: 0, null: false
    add_index :tournaments, :comments_count
  end
end
