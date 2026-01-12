class TournamentTheme < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  has_many :tournaments, dependent: :nullify

  # Validations
  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 100 }
  validates :slug, presence: true, uniqueness: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(display_order: :asc, name: :asc) }

  # Ransack whitelist
  def self.ransackable_attributes(_auth_object = nil)
    %w[id name slug description preview_image_url color_scheme display_order is_active created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[tournaments]
  end
end
