class AddCounterCacheToCricketMatchTypes < ActiveRecord::Migration[7.2]
  def change
    add_column :cricket_match_types, :tournaments_count, :integer, default: 0, null: false
    add_index :cricket_match_types, :tournaments_count
  end
end
