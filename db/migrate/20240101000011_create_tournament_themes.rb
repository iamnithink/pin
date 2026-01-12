class CreateTournamentThemes < ActiveRecord::Migration[7.2]
  def change
    create_table :tournament_themes do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :preview_image_url # URL or path to preview image
      t.string :color_scheme # JSON or string for theme colors
      t.integer :display_order, default: 0
      t.boolean :is_active, default: true
      t.timestamps null: false
    end

    add_index :tournament_themes, :slug, unique: true
    add_index :tournament_themes, :is_active
    add_index :tournament_themes, :display_order
  end
end
