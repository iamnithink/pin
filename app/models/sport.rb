class Sport < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  has_many :tournaments, dependent: :destroy, counter_cache: true
  has_many :teams, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(display_order: :asc, name: :asc) }

  # Cache
  def self.cached_active
    Rails.cache.fetch('sports_active', expires_in: 1.hour) do
      active.ordered.to_a
    end
  end

  # Ransack whitelist for Sport
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      name
      slug
      description
      icon
      display_order
      active
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[
      tournaments
      teams
    ]
  end
end

