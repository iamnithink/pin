class Api::V1::VenuesController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    venues = Venue.active
    venues = venues.by_pincode(params[:pincode]) if params[:pincode].present?
    venues = venues.limit(params[:limit] || 20)
    
    render_success(venues.map { |v| serialize_venue(v) })
  end

  def show
    venue = Venue.find(params[:id])
    render_success(serialize_venue(venue, detailed: true))
  end

  def create
    venue = current_user.created_venues.build(venue_params)
    
    if venue.save
      venue.generate_google_maps_link
      render_success(serialize_venue(venue, detailed: true), :created)
    else
      render_error(venue.errors.full_messages.join(', '))
    end
  end

  def update
    venue = current_user.created_venues.find(params[:id])
    
    if venue.update(venue_params)
      venue.generate_google_maps_link
      render_success(serialize_venue(venue, detailed: true))
    else
      render_error(venue.errors.full_messages.join(', '))
    end
  end

  private

  def venue_params
    params.require(:venue).permit(
      :name, :description, :address, :pincode, :city, :state,
      :country, :contact_phone, :contact_email, :hourly_rate
    )
  end

  def serialize_venue(venue, detailed: false)
    {
      id: venue.id,
      name: venue.name,
      description: venue.description,
      address: venue.address,
      pincode: venue.pincode,
      city: venue.city,
      state: venue.state,
      country: venue.country,
      latitude: venue.latitude,
      longitude: venue.longitude,
      google_maps_url: venue.google_maps_url,
      contact_phone: venue.contact_phone,
      contact_email: venue.contact_email,
      hourly_rate: venue.hourly_rate,
      is_verified: venue.is_verified
    }
  end
end

