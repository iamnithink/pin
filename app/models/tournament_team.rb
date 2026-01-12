class TournamentTeam < ApplicationRecord
  # Associations
  belongs_to :tournament
  belongs_to :team

  # Validations
  validates :tournament_id, uniqueness: { scope: :team_id }

  # Ransack whitelist for TournamentTeam
  def self.ransackable_attributes(_auth_object = nil)
    %w[id tournament_id team_id created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[tournament team]
  end
end
