class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  # Associations
  has_many :created_tournaments, class_name: 'Tournament', foreign_key: 'created_by_id', dependent: :nullify
  has_many :tournament_participants, dependent: :destroy
  has_many :tournaments, through: :tournament_participants
  has_many :teams_as_captain, class_name: 'Team', foreign_key: 'captain_id', dependent: :nullify
  has_many :team_members, dependent: :destroy
  has_many :teams, through: :team_members
  has_many :created_venues, class_name: 'Venue', foreign_key: 'created_by_id', dependent: :nullify
  has_many :tournament_likes, dependent: :destroy
  has_many :liked_tournaments, through: :tournament_likes, source: :tournament

  # Roles
  # Explicitly declare the attribute type for Rails 7.2+ enum support
  attribute :role, :string, default: 'user'
  enum role: {
    user: 'user',
    admin: 'admin',
    super_admin: 'super_admin'
  }

  # Callbacks
  before_validation :set_default_role, on: :create

  # Validations
  validates :phone, presence: true, uniqueness: true, format: { with: /\A\d{10}\z/ }
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :pincode, format: { with: /\A\d{6}\z/ }, allow_blank: true
  validates :role, presence: true, inclusion: { in: roles.keys }

  # Geocoding
  geocoded_by :address, latitude: :latitude, longitude: :longitude
  after_validation :geocode, if: ->(obj) { obj.address.present? && obj.address_changed? }

  # Scopes
  scope :verified, -> { where(phone_verified: true) }
  scope :by_pincode, ->(pincode) { where(pincode: pincode) }
  scope :super_admins, -> { where(role: 'super_admin') }
  scope :admins, -> { where(role: 'admin') }
  scope :users, -> { where(role: 'user') }
  scope :nearby, ->(lat, lng, radius = 10) {
    # Using Haversine formula for distance calculation (in km)
    # Approximate: 1 degree latitude ≈ 111 km
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

  # OTP methods
  def generate_otp
    self.otp_secret = rand(100000..999999).to_s
    self.otp_sent_at = Time.current
    save
    otp_secret
  end

  def verify_otp(otp)
    return false if otp_secret.blank? || otp_sent_at.blank?
    return false if otp_sent_at < 10.minutes.ago
    return false unless otp_secret == otp.to_s

    update(phone_verified: true, otp_secret: nil, otp_sent_at: nil)
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.avatar_url = auth.info.image
      user.password = Devise.friendly_token[0, 20]
      user.phone_verified = true
    end
  end

  def full_name
    name.presence || email.split('@').first
  end

  # Role helper methods
  def super_admin?
    role == 'super_admin'
  end

  def admin?
    role == 'admin' || super_admin?
  end

  def regular_user?
    role == 'user'
  end

  private

  def set_default_role
    self.role ||= 'user'
  end

  # Ransack (used by ActiveAdmin) requires an explicit whitelist of searchable attributes.
  # This avoids accidentally exposing sensitive columns (passwords, tokens, etc.).
  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      name
      email
      phone
      phone_verified
      pincode
      provider
      uid
      role
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[
      created_tournaments
      tournament_participants
      tournaments
      teams_as_captain
      team_members
      teams
      created_venues
    ]
  end
end

