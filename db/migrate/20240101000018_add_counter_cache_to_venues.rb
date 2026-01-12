class AddCounterCacheToVenues < ActiveRecord::Migration[7.2]
  def change
    add_column :venues, :tournaments_count, :integer, default: 0, null: false
    add_index :venues, :tournaments_count
  end
end
