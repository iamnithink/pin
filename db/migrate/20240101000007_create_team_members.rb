class CreateTeamMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :team_members do |t|
      t.references :team, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, default: 'member' # 'captain', 'vice_captain', 'member'
      t.boolean :is_active, default: true
      t.timestamps null: false
    end

    add_index :team_members, [:team_id, :user_id], unique: true
    add_index :team_members, :is_active
  end
end

