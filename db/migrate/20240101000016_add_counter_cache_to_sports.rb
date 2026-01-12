class AddCounterCacheToSports < ActiveRecord::Migration[7.2]
  def change
    add_column :sports, :tournaments_count, :integer, default: 0, null: false
    add_index :sports, :tournaments_count
  end
end
