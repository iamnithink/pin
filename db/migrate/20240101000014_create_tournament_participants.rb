class CreateTournamentParticipants < ActiveRecord::Migration[7.2]
  def change
    create_table :tournament_participants do |t|
      t.references :tournament, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :team, null: true, foreign_key: true
      t.string :status, default: 'pending' # 'pending', 'confirmed', 'cancelled'
      t.string :role # 'player', 'spectator', 'organizer'
      t.timestamps null: false
    end

    add_index :tournament_participants, [:tournament_id, :user_id], unique: true
    add_index :tournament_participants, :status
  end
end
