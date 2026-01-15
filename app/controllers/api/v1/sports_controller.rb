class Api::V1::SportsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    sports = Sport.cached_active
    render_success(sports.map { |s| serialize_sport(s) })
  end

  def show
    sport = Sport.find_by!(slug: params[:id])
    render_success(serialize_sport(sport, include_matches: true))
  end

  private

  def serialize_sport(sport, include_matches: false)
    data = {
      id: sport.id,
      name: sport.name,
      slug: sport.slug,
      description: sport.description,
      icon: sport.icon,
      active: sport.active
    }
    if include_matches
      # Eager load venue to avoid N+1 queries
      matches = sport.matches.approved.upcoming.includes(:venue).limit(10)
      data[:matches] = matches.map { |m| serialize_match(m) }
    end
    data
  end

  def serialize_match(match)
    {
      id: match.id,
      title: match.title,
      slug: match.slug,
      start_time: match.start_time,
      venue: {
        name: match.venue.name,
        address: match.venue.address,
        google_maps_url: match.venue.google_maps_url
      }
    }
  end
end

