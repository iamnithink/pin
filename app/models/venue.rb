class Venue < ApplicationRecord
  # Associations
  belongs_to :created_by, class_name: 'User'
  has_many :tournaments, dependent: :nullify, counter_cache: true

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 200 }
  validates :address, presence: true
  validates :pincode, presence: true, format: { with: /\A\d{6}\z/ }
  validates :latitude, :longitude, presence: true

  # Geocoding
  geocoded_by :full_address, latitude: :latitude, longitude: :longitude
  after_validation :geocode, if: ->(obj) { obj.address.present? && (obj.address_changed? || obj.pincode_changed?) }

  # Scopes
  scope :verified, -> { where(is_verified: true) }
  scope :active, -> { where(is_active: true) }
  scope :by_pincode, ->(pincode) { where(pincode: pincode) }
  scope :nearby, ->(lat, lng, radius = 10) {
    # Using Haversine formula for distance calculation (in km)
    lat_range = radius / 111.0
    lng_range = radius / (111.0 * Math.cos(lat * Math::PI / 180.0))
    
    where(
      "latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?",
      lat - lat_range, lat + lat_range, lng - lng_range, lng + lng_range
    ).where(
      "(6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) <= ?",
      lat, lng, lat, radius
    )
  }

  def full_address
    [address, city, state, pincode, country].compact.join(', ')
  end

  def google_maps_url
    return google_maps_link if google_maps_link.present?
    return nil unless latitude.present? && longitude.present?
    "https://www.google.com/maps?q=#{latitude},#{longitude}"
  end

  def generate_google_maps_link
    return if latitude.blank? || longitude.blank?
    self.google_maps_link = "https://www.google.com/maps?q=#{latitude},#{longitude}"
    save
  end

  # Ransack whitelist for Venue
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      name
      description
      address
      pincode
      city
      state
      country
      latitude
      longitude
      google_maps_link
      contact_phone
      contact_email
      hourly_rate
      is_verified
      is_active
      created_by_id
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[
      created_by
      tournaments
    ]
  end
end

