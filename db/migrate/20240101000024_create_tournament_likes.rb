class CreateTournamentLikes < ActiveRecord::Migration[7.2]
  def change
    create_table :tournament_likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :tournament, null: false, foreign_key: true
      t.timestamps null: false
    end

    add_index :tournament_likes, [:user_id, :tournament_id], unique: true
    # Note: tournament_id index is automatically created by t.references :tournament above
  end
end
