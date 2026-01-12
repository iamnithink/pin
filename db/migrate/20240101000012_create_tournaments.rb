class CreateTournaments < ActiveRecord::Migration[7.2]
  def change
    create_table :tournaments do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.references :sport, null: false, foreign_key: true
      t.references :cricket_match_type, null: true, foreign_key: true
      t.references :venue, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :tournament_theme, null: true, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.integer :max_players_per_team
      t.integer :min_players_per_team
      t.decimal :entry_fee
      t.string :tournament_status, default: 'draft' # 'draft', 'published', 'cancelled', 'completed', 'live'
      t.string :pincode, null: false
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.integer :view_count, default: 0
      t.integer :join_count, default: 0
      t.boolean :is_featured, default: false
      t.boolean :is_active, default: true
      t.timestamps null: false
    end

    add_index :tournaments, :slug, unique: true
    add_index :tournaments, :pincode
    add_index :tournaments, [:latitude, :longitude]
    add_index :tournaments, :start_time
    add_index :tournaments, :tournament_status
    add_index :tournaments, :is_active
    add_index :tournaments, :is_featured
    add_index :tournaments, [:sport_id, :pincode, :tournament_status, :start_time], name: 'index_tournaments_on_discovery'
  end
end
