class Tournament < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Associations
  belongs_to :sport
  belongs_to :cricket_match_type, optional: true
  belongs_to :venue, optional: true
  belongs_to :created_by, class_name: 'User'
  belongs_to :tournament_theme, optional: true
  has_many :tournament_participants, dependent: :destroy
  has_many :participants, through: :tournament_participants, source: :user
  has_many :tournament_teams, dependent: :destroy
  has_many :teams, through: :tournament_teams
  has_many :tournament_likes, dependent: :destroy
  has_many :liked_by_users, through: :tournament_likes, source: :user
  has_many :comments, dependent: :destroy
  has_many :top_level_comments, -> { where(parent_id: nil).order(created_at: :desc) }, class_name: 'Comment'

  # ActionText for rules and regulations
  has_rich_text :rules_and_regulations

  # ActiveStorage - for tournament image upload (Cloudinary free tier: 25GB storage, 25GB bandwidth/month)
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [300, 300]
    attachable.variant :medium, resize_to_limit: [800, 800]
  end
  
  # Virtual attribute for image deletion checkbox in ActiveAdmin
  attr_accessor :remove_image
  
  # Validate image if attached
  validate :validate_image, if: -> { image.attached? }

  # Serialize prizes JSON
  serialize :prizes_json, coder: JSON, type: Hash
  
  # Serialize contact phones as JSON array
  serialize :contact_phones, coder: JSON, type: Array

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :start_time, presence: true
  validates :pincode, presence: true, format: { with: /\A\d{6}\z/ }
  validates :tournament_status, inclusion: { in: %w[draft published cancelled completed live] }
  validate :start_time_in_future, on: :create
  validate :cricket_match_type_for_cricket
  validate :image_or_theme_present, if: :published?

  # Geocoding
  geocoded_by :venue_address, latitude: :latitude, longitude: :longitude
  after_validation :geocode_from_venue, if: -> { venue.present? }

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :draft, -> { where(tournament_status: 'draft') }
  scope :published, -> { where(tournament_status: 'published') }
  scope :cancelled, -> { where(tournament_status: 'cancelled') }
  scope :completed, -> { where(tournament_status: 'completed') }
  scope :upcoming, -> { where('start_time > ?', Time.current) }
  scope :by_sport, ->(sport_id) { where(sport_id: sport_id) }
  scope :by_pincode, ->(pincode) { where(pincode: pincode) }
  scope :by_status, ->(status) { where(tournament_status: status) }
  scope :featured, -> { where(is_featured: true) }
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
  scope :discovery, ->(sport_id: nil, pincode: nil, status: 'published') {
    scope = published.where(tournament_status: status).upcoming
    scope = scope.where(sport_id: sport_id) if sport_id.present?
    scope = scope.where(pincode: pincode) if pincode.present?
    scope.order(start_time: :asc)
  }

  # Callbacks
  before_save :set_location_from_venue
  after_create :increment_view_count

  # Cache
  def self.cached_discovery(sport_id: nil, pincode: nil, limit: 20)
    cache_key = "tournaments_discovery_#{sport_id}_#{pincode}_#{limit}"
    Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      discovery(sport_id: sport_id, pincode: pincode).limit(limit).includes(:sport, :venue, :created_by, :tournament_theme).to_a
    end
  end

  def venue_address
    self[:venue_address].presence || venue&.full_address
  end

  def geocode_from_venue
    # Use venue association if available
    if venue.present?
      self.latitude = venue.latitude if venue.latitude.present?
      self.longitude = venue.longitude if venue.longitude.present?
      self.pincode = venue.pincode if venue.pincode.present?
    end
  end

  def set_location_from_venue
    # Use venue association if available
    if venue.present?
      self.latitude ||= venue.latitude if venue.latitude.present?
      self.longitude ||= venue.longitude if venue.longitude.present?
      self.pincode ||= venue.pincode if venue.pincode.present?
    end
  end

  def start_time_in_future
    return unless start_time.present?
    errors.add(:start_time, 'must be in the future') if start_time < Time.current
  end

  def cricket_match_type_for_cricket
    return unless sport&.name&.downcase == 'cricket'
    return if cricket_match_type.present?
    errors.add(:cricket_match_type, 'is required for cricket tournaments')
  end

  def image_or_theme_present
    return if image.attached? || tournament_theme.present?
    errors.add(:base, 'Either tournament image or theme must be selected before publishing')
  end

  def validate_image
    return unless image.attached?
    
    # Check file size (max 10MB)
    if image.byte_size > 10.megabytes
      errors.add(:image, 'is too large. Maximum size is 10MB.')
    end
    
    # Check content type
    unless image.content_type.in?(%w[image/jpeg image/jpg image/png image/gif image/webp])
      errors.add(:image, 'must be a JPEG, PNG, GIF, or WebP image.')
    end
  end

  def increment_view_count
    increment!(:view_count)
  end

  def google_maps_url
    return venue.google_maps_url if venue.present?
    return nil unless latitude.present? && longitude.present?
    "https://www.google.com/maps?q=#{latitude},#{longitude}"
  end

  def can_join?(user)
    return false unless published?
    return false if start_time < Time.current
    return false if tournament_participants.where(user: user).exists?
    return false if max_players_per_team.present? && participants.count >= max_players_per_team * 2
    true
  end

  def published?
    tournament_status == 'published'
  end

  # Calculate distance from given coordinates (in km)
  def distance_from(lat, lng)
    return nil unless latitude.present? && longitude.present? && lat.present? && lng.present?
    
    # Haversine formula
    rad_per_deg = Math::PI / 180
    rkm = 6371 # Earth radius in kilometers
    
    dlat_rad = (latitude - lat) * rad_per_deg
    dlon_rad = (longitude - lng) * rad_per_deg
    
    lat1_rad = lat * rad_per_deg
    lat2_rad = latitude * rad_per_deg
    
    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    
    (rkm * c).round(2)
  end

  def publish!
    return false unless valid?
    update(tournament_status: 'published')
  end

  def unpublish!
    update(tournament_status: 'draft')
  end

  # Prize methods
  def prizes
    result = {}
    result['first'] = first_prize if first_prize.present?
    result['second'] = second_prize if second_prize.present?
    result['third'] = third_prize if third_prize.present?
    result.merge!(prizes_json) if prizes_json.present?
    result
  end

  def prizes_list
    prizes.map { |level, amount| { level: level, amount: amount } }
  end

  def formatted_prizes
    prizes.map { |level, amount| "#{level.humanize}: ₹#{amount}" }.join(', ')
  end

  # Ransack (ActiveAdmin search) whitelist for Tournament
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      title
      description
      sport_id
      cricket_match_type_id
      venue_id
      created_by_id
      tournament_theme_id
      start_time
      end_time
      max_players_per_team
      min_players_per_team
      entry_fee
      tournament_status
      pincode
      latitude
      longitude
      first_prize
      second_prize
      third_prize
      prizes_json
      view_count
      join_count
      is_featured
      is_active
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[
      sport
      cricket_match_type
      venue
      created_by
      tournament_theme
      tournament_participants
      participants
      tournament_teams
      teams
      image_attachment
      image_blob
    ]
  end
end
