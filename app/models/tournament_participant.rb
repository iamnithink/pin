class TournamentParticipant < ApplicationRecord
  # Associations
  belongs_to :tournament
  belongs_to :user
  belongs_to :team, optional: true

  # Validations
  validates :user_id, uniqueness: { scope: :tournament_id }
  validates :status, inclusion: { in: %w[pending confirmed cancelled] }
  validates :role, inclusion: { in: %w[player spectator organizer] }, allow_nil: true

  # Scopes
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :pending, -> { where(status: 'pending') }
end
