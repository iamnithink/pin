class CreateCricketMatchTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :cricket_match_types do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :team_size, null: false
      t.string :category, null: false # 'full_ground', 'supersix'
      t.string :sub_category # 'overarm_bowling', 'underarm_bowling', 'legspin_action_only', 'all_action_bowling'
      t.text :description
      t.boolean :active, default: true
      t.timestamps null: false
    end

    add_index :cricket_match_types, :slug, unique: true
    add_index :cricket_match_types, :team_size
    add_index :cricket_match_types, :category
    add_index :cricket_match_types, :active
  end
end

