class Team < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  belongs_to :sport
  belongs_to :captain, class_name: 'User'
  has_many :team_members, dependent: :destroy
  has_many :members, through: :team_members, source: :user
  has_many :tournament_teams, dependent: :destroy
  has_many :tournaments, through: :tournament_teams

  # ActionText for description
  has_rich_text :description

  # ActiveStorage
  has_one_attached :logo

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :slug, presence: true, uniqueness: true

  # Callbacks
  before_save :update_member_count

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :by_sport, ->(sport_id) { where(sport_id: sport_id) }
  scope :default_teams, -> { where(is_default: true) }
  scope :user_teams, -> { where(is_default: false) }

  def update_member_count
    self.member_count = team_members.active.count
  end

  def all_tournaments
    tournaments
  end

  # Ransack whitelist for Team
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      name
      slug
      description
      sport_id
      captain_id
      member_count
      is_active
      is_default
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[
      sport
      captain
      team_members
      members
      tournament_teams
      tournaments
      logo_attachment
      logo_blob
    ]
  end
end

