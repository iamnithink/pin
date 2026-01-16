Geocoder.configure(
  lookup: :google,
  api_key: ENV.fetch('GOOGLE_MAPS_API_KEY', nil),
  timeout: 15,
  units: :km,
  use_https: true,
  # Handle SSL verification issues in development/seeding
  http_headers: { "User-Agent" => "Rails Geocoder" }
)

