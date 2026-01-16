require 'faker'
require_relative '../lib/tournament_theme_templates'

puts "=" * 60
puts "Seeding database with role-based access control..."
puts "=" * 60

########################################
# Users with Roles (Super Admin, Admin, Regular Users)
########################################

puts "\n[1/8] Creating users with roles..."

# Super Admin
super_admin = User.find_by(email: 'superadmin@playinnear.com') || User.find_by(phone: '9000000000')
if super_admin.nil?
  super_admin = User.create!(
    email: 'superadmin@playinnear.com',
    name: 'Super Administrator',
    phone: '9000000000',
    password: 'admin123456',
    password_confirmation: 'admin123456',
    pincode: '560001',
    address: 'Bangalore, Karnataka, India',
    phone_verified: true,
    role: 'super_admin',
    latitude: 12.9716,
    longitude: 77.5946
  )
else
  # Update email if it's different (using update_columns to skip validations)
  super_admin.update_columns(email: 'superadmin@playinnear.com') if super_admin.email != 'superadmin@playinnear.com'
  # Update coordinates if missing (using update_columns to skip validations)
  super_admin.update_columns(latitude: 12.9716, longitude: 77.5946) if super_admin.latitude.blank?
  # Update role if needed (using update_columns to skip validations)
  super_admin.update_columns(role: 'super_admin') unless super_admin.super_admin?
end
puts "  ✓ Super Admin: #{super_admin.email} (password: admin123456)"

# Admin
admin = User.find_by(email: 'admin@playinnear.com') || User.find_by(phone: '9000000001')
if admin.nil?
  admin = User.create!(
    email: 'admin@playinnear.com',
    name: 'Administrator',
    phone: '9000000001',
    password: 'admin123456',
    password_confirmation: 'admin123456',
    pincode: '560001',
    address: 'Bangalore, Karnataka, India',
    phone_verified: true,
    role: 'admin',
    latitude: 12.9716,
    longitude: 77.5946
  )
else
  # Update email if it's different (using update_columns to skip validations)
  admin.update_columns(email: 'admin@playinnear.com') if admin.email != 'admin@playinnear.com'
  # Update coordinates if missing (using update_columns to skip validations)
  admin.update_columns(latitude: 12.9716, longitude: 77.5946) if admin.latitude.blank?
  # Update role if needed (using update_columns to skip validations)
  admin.update_columns(role: 'admin') unless admin.admin?
end
puts "  ✓ Admin: #{admin.email} (password: admin123456)"

# Regular Users (15 users)
users = []
15.times do |i|
  email = "user#{i + 1}@example.com"
  phone = "90000#{format('%05d', i + 2)}"[0, 10]
  user = User.find_by(email: email) || User.find_by(phone: phone)
  
  if user.nil?
    user = User.create!(
      email: email,
      name: Faker::Name.name,
      phone: phone,
      password: 'password123',
      password_confirmation: 'password123',
      pincode: format("5600%02d", rand(0..99)),
      address: Faker::Address.full_address,
      phone_verified: [true, false].sample,
      role: 'user',
      latitude: 12.9716 + (rand - 0.5) * 0.1,
      longitude: 77.5946 + (rand - 0.5) * 0.1
    )
  else
    # Update email if different (using update_columns to skip validations)
    user.update_columns(email: email) if user.email != email
    # Don't update phone if user already exists - phone numbers are unique
    # Update coordinates if missing
    if user.latitude.blank?
      user.update_columns(
        latitude: 12.9716 + (rand - 0.5) * 0.1,
        longitude: 77.5946 + (rand - 0.5) * 0.1
      )
    end
    # Update role if needed
    user.update_columns(role: 'user') unless user.regular_user?
  end
  users << user
end
puts "  ✓ Created/Updated #{users.count} regular users"

all_users = [super_admin, admin] + users
puts "  Total users: #{all_users.count} (1 super_admin, 1 admin, #{users.count} users)"

########################################
# Sports (4 main sports)
########################################

puts "\n[2/8] Creating sports..."

sports_data = [
  { name: 'Cricket',    description: 'Cricket matches and tournaments',    icon: '🏏', display_order: 1 },
  { name: 'Volleyball', description: 'Volleyball matches and tournaments', icon: '🏐', display_order: 2 },
  { name: 'Football',   description: 'Football matches and tournaments',   icon: '⚽', display_order: 3 },
  { name: 'Badminton',  description: 'Badminton matches and tournaments',  icon: '🏸', display_order: 4 }
]

sports = sports_data.map do |attrs|
  Sport.find_or_create_by!(name: attrs[:name]) do |s|
    s.description    = attrs[:description]
    s.icon           = attrs[:icon]
    s.display_order  = attrs[:display_order]
    s.active         = true
  end
end
puts "  ✓ Sports: #{sports.map(&:name).join(', ')}"

cricket = sports.find { |s| s.name == 'Cricket' }

########################################
# Venues (15)
########################################

puts "\n[3/8] Creating venues..."

venues = 15.times.map do |i|
  Venue.find_or_create_by!(name: "Ground #{i + 1}") do |v|
    v.description   = "Local ground #{i + 1} for sports activities"
    v.address       = Faker::Address.street_address
    v.city          = 'Bengaluru'
    v.state         = 'Karnataka'
    v.country       = 'India'
    v.pincode       = format("5600%02d", rand(0..99))
    v.latitude      = 12.9 + rand * 0.1
    v.longitude     = 77.5 + rand * 0.1
    v.contact_phone = "98800#{format('%05d', i)}"[0, 10]
    v.contact_email = "venue#{i + 1}@example.com"
    v.hourly_rate   = rand(200..800)
    v.is_verified   = [true, false].sample
    v.is_active     = true
    v.created_by    = all_users.sample
  end
end
puts "  ✓ Created #{venues.count} venues"

########################################
# Cricket match types (7)
########################################

puts "\n[4/8] Creating cricket match types..."

if cricket
  cricket_types_data = [
    { name: 'Full Ground (11) - Overarm',      team_size: 11, category: 'full_ground', sub_category: 'overarm_bowling' },
    { name: 'Full Ground (11) - Underarm',    team_size: 11, category: 'full_ground', sub_category: 'underarm_bowling' },
    { name: 'Full Ground (11) - Legspin',     team_size: 11, category: 'full_ground', sub_category: 'legspin_action_only' },
    { name: 'Full Ground (11) - All Action',  team_size: 11, category: 'full_ground', sub_category: 'all_action_bowling' },
    { name: 'SuperSix (7)',                   team_size: 7,  category: 'supersix',     sub_category: nil },
    { name: 'SuperSix (5)',                   team_size: 5,  category: 'supersix',     sub_category: nil },
    { name: 'SuperSix (3)',                   team_size: 3,  category: 'supersix',     sub_category: nil }
  ]

  cricket_types = cricket_types_data.map do |attrs|
    CricketMatchType.find_or_create_by!(name: attrs[:name]) do |t|
      t.team_size    = attrs[:team_size]
      t.category     = attrs[:category]
      t.sub_category = attrs[:sub_category]
      t.active       = true
    end
  end
  puts "  ✓ Created #{cricket_types.count} cricket match types"
else
  cricket_types = []
  puts "  ⚠ Cricket sport not found, skipping cricket match types"
end

########################################
# Tournament Themes (3 default themes with HTML templates)
########################################

puts "\n[5/8] Creating tournament themes..."

themes_data = [
  { 
    name: 'Classic Blue', 
    description: 'Professional blue theme for tournaments (based on sample design)', 
    preview_image_url: nil, 
    color_scheme: '{"primary": "#000080", "secondary": "#FFD700", "accent": "#DC143C"}', 
    display_order: 1,
    template_html: TournamentThemeTemplates::CLASSIC_BLUE
  },
  { 
    name: 'Fire Red', 
    description: 'Energetic red theme for competitive tournaments', 
    preview_image_url: nil, 
    color_scheme: '{"primary": "#8B0000", "secondary": "#FFD700", "accent": "#FFA500"}', 
    display_order: 2,
    template_html: TournamentThemeTemplates::FIRE_RED
  },
  { 
    name: 'Forest Green', 
    description: 'Natural green theme for outdoor tournaments', 
    preview_image_url: nil, 
    color_scheme: '{"primary": "#006400", "secondary": "#90EE90", "accent": "#FFD700"}', 
    display_order: 3,
    template_html: TournamentThemeTemplates::FOREST_GREEN
  }
]

themes = themes_data.map do |attrs|
  theme = TournamentTheme.find_or_create_by!(name: attrs[:name]) do |t|
    t.description      = attrs[:description]
    t.preview_image_url = attrs[:preview_image_url]
    t.color_scheme     = attrs[:color_scheme]
    t.display_order   = attrs[:display_order]
    t.template_html   = attrs[:template_html]
    t.is_active       = true
  end
  # Always update template_html to ensure latest structure
  theme.update!(
    template_html: attrs[:template_html],
    description: attrs[:description],
    color_scheme: attrs[:color_scheme],
    display_order: attrs[:display_order]
  )
  theme
end
puts "  ✓ Created #{themes.count} tournament themes: #{themes.map(&:name).join(', ')}"

########################################
# Teams (20) – mix of default (admin) and user teams
########################################

puts "\n[6/8] Creating teams..."

# Default teams created by admin (10 teams)
default_teams = 10.times.map do |i|
  sport = sports.sample
  captain = all_users.sample

  Team.find_or_create_by!(name: "Default Team #{sport.name} #{i + 1}") do |t|
    t.description = "Default team #{i + 1} for #{sport.name} (created by Admin)"
    t.sport       = sport
    t.captain     = captain
    t.is_default  = true
    t.is_active   = true
  end
end

# User-created teams (10 teams)
user_teams = 10.times.map do |i|
  sport = sports.sample
  captain = all_users.sample

  Team.find_or_create_by!(name: "User Team #{sport.name} #{i + 1}") do |t|
    t.description = "User team #{i + 1} for #{sport.name}"
    t.sport       = sport
    t.captain     = captain
    t.is_default  = false
    t.is_active   = true
  end
end

all_teams = default_teams + user_teams
puts "  ✓ Created #{default_teams.count} default teams and #{user_teams.count} user teams"

########################################
# Tournaments (40 total: 25 Cricket + 15 Other sports)
########################################

puts "\n[7/8] Creating tournaments..."

tournament_statuses = %w[draft published completed cancelled]

# Helper method to round to nearest 1000
def round_to_thousand(value)
  (value / 1000.0).round * 1000
end

# Helper method to round prize amounts
def round_prize(value)
  if value >= 10000
    round_to_thousand(value)
  elsif value >= 1000
    ((value / 500.0).round * 500)
  else
    ((value / 100.0).round * 100)
  end
end

tournaments = []

# Create 25 Cricket tournaments
cricket_tournament_titles = [
  "Summer Cricket Championship", "Bangalore Premier League", "City Cricket Cup",
  "Corporate Cricket Tournament", "Weekend Warriors League", "Cricket Masters Cup",
  "Local Cricket Championship", "Community Cricket League", "Elite Cricket Tournament",
  "Cricket Super Series", "T20 Cricket Challenge", "Cricket Champions Trophy",
  "Metro Cricket League", "Cricket Premier Cup", "Cricket Excellence Tournament",
  "Cricket Victory Cup", "Cricket Glory League", "Cricket Power Series",
  "Cricket Elite Championship", "Cricket Star League", "Cricket Diamond Cup",
  "Cricket Gold Tournament", "Cricket Silver League", "Cricket Bronze Cup",
  "Cricket Classic Championship"
]

25.times do |i|
  creator     = all_users.sample
  venue       = venues.sample
  start_time  = Time.current + (i + 1).days + rand(0..12).hours
  c_type      = cricket_types.sample
  theme       = themes.sample
  selected_teams = all_teams.select { |t| t.sport == cricket }.sample(rand(4..8))

  # Generate rounded entry fees (1000, 2000, 3000, etc. up to 10000)
  entry_fee_options = [1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 10000]
  entry_fee = entry_fee_options.sample

  # Generate rounded prize amounts
  first_prize_base = [10000, 20000, 30000, 40000, 50000, 60000, 75000, 100000].sample
  first_prize = round_prize(first_prize_base)
  second_prize = round_prize(first_prize * 0.6)
  third_prize = round_prize(first_prize * 0.3)
  
  # Additional prizes (4th, 5th place) as hash
  additional_prizes = {
    'fourth' => round_prize(first_prize * 0.15),
    'fifth' => round_prize(first_prize * 0.1)
  }
  # Sometimes add more prizes
  if rand > 0.4
    additional_prizes['sixth'] = round_prize(first_prize * 0.05)
  end

  # Generate contact phones (2-3 phone numbers)
  contact_phones = []
  rand(2..3).times do
    contact_phones << "9#{rand(100000000..999999999)}"
  end
  
  # Generate teams text for cricket
  cricket_team_names = [
    "Royal Challengers", "Super Kings", "Mumbai Indians", "Delhi Capitals",
    "Kolkata Knights", "Sunrisers", "Punjab Kings", "Rajasthan Royals",
    "Bangalore Strikers", "Chennai Warriors", "Mumbai Mavericks", "Delhi Dynamos"
  ]
  teams_text = cricket_team_names.sample(rand(4..8)).join("\n")
  
  # Generate Google Maps link
  gmap_link = "https://www.google.com/maps?q=#{venue.latitude},#{venue.longitude}"
  
  # Generate organizer name for cricket
  organizer_names = [
    "Cricket Sports Club",
    "Local Cricket Association",
    "Bangalore Cricket League",
    "Community Cricket Committee",
    "Cricket Championship Organizers",
    "Elite Cricket Foundation",
    "Premier Cricket Council"
  ]
  organizer_name = organizer_names.sample
  
  tournament = Tournament.find_or_create_by!(title: cricket_tournament_titles[i] || "Cricket Tournament #{i + 1}", venue: venue, start_time: start_time) do |t|
    t.description           = "#{cricket_tournament_titles[i] || "Cricket Tournament #{i + 1}"} - A competitive cricket tournament featuring #{c_type.name}. Join us for exciting matches and great prizes!"
    t.sport                 = cricket
    t.cricket_match_type    = c_type
    t.created_by            = creator
    t.organized_by          = organizer_name
    t.tournament_theme      = theme
    t.end_time              = start_time + 3.hours
    t.max_players_per_team  = c_type.team_size
    t.min_players_per_team  = [3, 5, 7].sample
    t.entry_fee             = entry_fee
    t.tournament_status     = tournament_statuses.sample
    t.pincode               = venue.pincode
    t.latitude              = venue.latitude
    t.longitude             = venue.longitude
    t.view_count            = rand(10..200)
    t.join_count            = rand(5..50)
    t.is_featured           = i < 5 # First 5 are featured
    t.is_active             = true
    t.first_prize           = first_prize
    t.second_prize          = second_prize
    t.third_prize           = third_prize
    t.prizes_json           = additional_prizes
    t.venue_address         = venue.full_address
    t.venue_google_maps_link = gmap_link
    t.contact_phones        = contact_phones
    t.teams_text            = teams_text
  end

  # Associate teams with tournament
  selected_teams.each do |team|
    TournamentTeam.find_or_create_by!(tournament: tournament, team: team)
  end

  tournaments << tournament
end

# Create 15 tournaments for other sports
other_sports = sports.reject { |s| s.name == 'Cricket' }

15.times do |i|
  sport       = other_sports.sample
  creator     = all_users.sample
  venue       = venues.sample
  start_time  = Time.current + (i + 26).days + rand(0..12).hours
  theme       = themes.sample
  selected_teams = all_teams.select { |t| t.sport == sport }.sample(rand(2..4))

  # Generate rounded entry fees
  entry_fee_options = [1000, 2000, 3000, 4000, 5000]
  entry_fee = entry_fee_options.sample

  # Generate rounded prize amounts
  first_prize_base = [10000, 20000, 30000, 40000, 50000].sample
  first_prize = round_prize(first_prize_base)
  second_prize = round_prize(first_prize * 0.6)
  third_prize = round_prize(first_prize * 0.3)
  
  additional_prizes = {
    'fourth' => round_prize(first_prize * 0.15),
    'fifth' => round_prize(first_prize * 0.1)
  }

  # Generate contact phones
  contact_phones = []
  rand(2..3).times do
    contact_phones << "9#{rand(100000000..999999999)}"
  end
  
  # Generate teams text
  team_names = ["Team #{sport.name} Alpha", "Team #{sport.name} Beta", "Team #{sport.name} Gamma", "Team #{sport.name} Delta"]
  teams_text = team_names.sample(rand(2..4)).join("\n")
  
  # Generate Google Maps link
  gmap_link = "https://www.google.com/maps?q=#{venue.latitude},#{venue.longitude}"
  
  # Generate organizer name
  organizer_names = [
    "#{sport.name} Sports Club",
    "Local #{sport.name} Association",
    "#{creator.name}'s Tournament",
    "Community #{sport.name} League",
    "#{sport.name} Championship Committee"
  ]
  organizer_name = organizer_names.sample
  
  tournament = Tournament.find_or_create_by!(title: "#{sport.name} Tournament #{i + 1}", venue: venue, start_time: start_time) do |t|
    t.description           = "Sample #{sport.name} tournament #{i + 1} - Join us for exciting matches!"
    t.sport                 = sport
    t.cricket_match_type    = nil
    t.created_by            = creator
    t.organized_by          = organizer_name
    t.tournament_theme      = theme
    t.end_time              = start_time + 2.hours
    t.max_players_per_team  = 7
    t.min_players_per_team  = 3
    t.entry_fee             = entry_fee
    t.tournament_status     = tournament_statuses.sample
    t.pincode               = venue.pincode
    t.latitude              = venue.latitude
    t.longitude             = venue.longitude
    t.view_count            = rand(5..100)
    t.join_count            = rand(2..30)
    t.is_featured           = [true, false].sample
    t.is_active             = true
    t.first_prize           = first_prize
    t.second_prize          = second_prize
    t.third_prize           = third_prize
    t.prizes_json           = additional_prizes
    t.venue_address         = venue.full_address
    t.venue_google_maps_link = gmap_link
    t.contact_phones        = contact_phones
    t.teams_text            = teams_text
  end

  # Associate teams with tournament
  selected_teams.each do |team|
    TournamentTeam.find_or_create_by!(tournament: tournament, team: team)
  end

  tournaments << tournament
end

puts "  ✓ Created #{tournaments.count} tournaments"
puts "    - Cricket: #{tournaments.count { |t| t.sport == cricket }}"
puts "    - Other sports: #{tournaments.count { |t| t.sport != cricket }}"

########################################
# Tournament participants (simple join records)
########################################

puts "\n[8/8] Creating tournament participants..."

participant_count = 0
tournaments.each do |tournament|
  sample_users = all_users.sample(4)
  sample_users.each do |user|
    TournamentParticipant.find_or_create_by!(tournament: tournament, user: user) do |tp|
      tp.status = %w[pending confirmed].sample
      tp.role   = 'player'
    end
    participant_count += 1
  end
end
puts "  ✓ Created #{participant_count} tournament participant records"

########################################
# Summary
########################################

puts "\n" + "=" * 60
puts "Seed data created successfully!"
puts "=" * 60
puts "\nLogin Credentials:"
puts "  Super Admin: superadmin@playinnear.com / admin123456"
puts "  Admin:       admin@playinnear.com / admin123456"
puts "  Users:       user1@example.com to user15@example.com / password123"
puts "\nAccess:"
puts "  - ActiveAdmin: http://localhost:3000/admin (use super_admin or admin account)"
puts "  - Public Site: http://localhost:3000"
puts "\nRoles:"
puts "  - Super Admin: Full access to everything"
puts "  - Admin: Access to Dashboard, Teams, Tournaments, Venues"
puts "  - User: Access to own dashboard and tournaments"
puts "=" * 60
