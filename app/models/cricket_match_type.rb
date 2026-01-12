class CricketMatchType < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  has_many :tournaments, dependent: :nullify, counter_cache: true

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :team_size, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true, inclusion: { in: %w[full_ground supersix] }
  validates :sub_category, inclusion: {
    in: %w[overarm_bowling underarm_bowling legspin_action_only all_action_bowling],
    allow_nil: true
  }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_category, ->(cat) { where(category: cat) }
  scope :by_team_size, ->(size) { where(team_size: size) }

  # Cache
  def self.cached_active
    Rails.cache.fetch('cricket_match_types_active', expires_in: 1.hour) do
      active.to_a
    end
  end

  def display_name
    parts = [name]
    parts << sub_category.humanize if sub_category.present?
    parts.join(' - ')
  end

  # Ransack whitelist for CricketMatchType
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      name
      slug
      description
      team_size
      category
      sub_category
      active
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[
      tournaments
    ]
  end
end

