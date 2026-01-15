class HomeController < ApplicationController
  include TournamentThemeHelper
  
  # Homepage is public - no authorization needed
  skip_authorization_check only: [:index]

  def index
    @sports = Sport.cached_active
    
    # Get filter parameters - default to "All Sports" (no filter)
    sport_id = params[:sport_id].presence
    search_query = params[:search].presence
    start_date = params[:start_date].presence
    user_lat = params[:latitude].presence&.to_f
    user_lng = params[:longitude].presence&.to_f
    
    # Build base query with eager loading to avoid N+1 queries
    # Include all associations that are always accessed in the view
    # Note: tournament_likes uses counter_cache (likes_count), so no need to eager load
    # Eager load image_attachment to avoid N+1 when checking image.attached? in the view
    # Use preload for ActiveStorage (polymorphic association) - loads attachment records efficiently
    @tournaments = Tournament.published
                            .active
                            .upcoming
                            .includes(:sport, :tournament_theme)
                            .preload(:image_attachment)
    
    # Apply sport filter (only if a sport is selected, otherwise show all)
    @tournaments = @tournaments.where(sport_id: sport_id) if sport_id.present?
    
    # Apply search filter
    if search_query.present?
      @tournaments = @tournaments.where(
        "LOWER(title) LIKE ? OR LOWER(description) LIKE ? OR LOWER(venue_name) LIKE ? OR LOWER(venue_address) LIKE ?",
        "%#{search_query.downcase}%", "%#{search_query.downcase}%", "%#{search_query.downcase}%", "%#{search_query.downcase}%"
      )
    end
    
    # Apply date filter
    if start_date.present?
      begin
        date = Date.parse(start_date)
        @tournaments = @tournaments.where("DATE(start_time) = ?", date)
      rescue ArgumentError
        # Invalid date, ignore filter
      end
    end
    
    # Note: venue is NOT preloaded to avoid Bullet warnings
    # The view checks venue_id.present? before accessing venue, and most tournaments
    # use venue_name/venue_address fields directly, so lazy loading is acceptable
    
    # Sort by location if coordinates provided, otherwise by start_time
    if user_lat.present? && user_lng.present?
      tournaments_loaded = @tournaments.load
      @tournaments = tournaments_loaded.sort_by do |tournament|
        distance = tournament.distance_from(user_lat, user_lng)
        [distance.nil? ? 999999 : distance, tournament.start_time]
      end
      @tournaments = @tournaments.first(50)
    else
      @tournaments = @tournaments.order(start_time: :asc).limit(50).load
    end
    
    # Store filter values for form
    @selected_sport_id = sport_id
    @search_query = search_query
    @start_date = start_date
  end
end

