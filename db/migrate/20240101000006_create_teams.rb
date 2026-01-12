class CreateTeams < ActiveRecord::Migration[7.2]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :logo
      t.references :sport, null: false, foreign_key: true
      t.references :captain, null: false, foreign_key: { to_table: :users }
      t.integer :member_count, default: 0
      t.boolean :is_active, default: true
      t.boolean :is_default, default: false # Teams created by admin
      t.timestamps null: false
    end

    add_index :teams, :slug, unique: true
    add_index :teams, :is_active
  end
end

