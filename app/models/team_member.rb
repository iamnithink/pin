class TeamMember < ApplicationRecord
  # Associations
  belongs_to :team
  belongs_to :user

  # Validations
  validates :user_id, uniqueness: { scope: :team_id }
  validates :role, inclusion: { in: %w[captain vice_captain member] }

  # Scopes
  scope :active, -> { where(is_active: true) }
end

