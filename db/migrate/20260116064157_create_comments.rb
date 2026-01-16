class CreateComments < ActiveRecord::Migration[7.2]
  def change
    unless table_exists?(:comments)
      create_table :comments do |t|
        t.text :body, null: false
        t.references :user, null: false, foreign_key: true
        t.references :tournament, null: false, foreign_key: true
        t.references :parent, null: true, foreign_key: { to_table: :comments }, index: true

        t.timestamps
      end
    end

    # Ensure indexes exist (parent_id index is automatically created by t.references above with index: true)
    add_index :comments, [:tournament_id, :created_at] unless index_exists?(:comments, [:tournament_id, :created_at])
    add_index :comments, [:user_id, :created_at] unless index_exists?(:comments, [:user_id, :created_at])
  end
end
