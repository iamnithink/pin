class CreateSports < ActiveRecord::Migration[7.2]
  def change
    create_table :sports do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :icon
      t.integer :display_order, default: 0
      t.boolean :active, default: true
      t.timestamps null: false
    end

    add_index :sports, :slug, unique: true
    add_index :sports, :active
    add_index :sports, :display_order
  end
end

