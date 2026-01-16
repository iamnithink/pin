class HomeController < ApplicationController
  include TournamentThemeHelper
  
  # Homepage is public - no authorization needed
  skip_authorization_check only: [:index, :load_more]

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
    # Note: venue is NOT eager loaded - it's only accessed conditionally as fallback when venue_address is blank
    # Most tournaments use venue_address field directly, so lazy loading is acceptable for rare cases
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
        "LOWER(title) LIKE ? OR LOWER(description) LIKE ? OR LOWER(venue_address) LIKE ?",
        "%#{search_query.downcase}%", "%#{search_query.downcase}%", "%#{search_query.downcase}%"
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
    
    # Pagination for infinite scroll - load 20 tournaments per page
    page = params[:page].to_i
    page = 1 if page < 1
    per_page = 20
    
    # Build base query for counting (without eager loading for performance)
    count_query = Tournament.published.active.upcoming
    count_query = count_query.where(sport_id: sport_id) if sport_id.present?
    if search_query.present?
      count_query = count_query.where(
        "LOWER(title) LIKE ? OR LOWER(description) LIKE ? OR LOWER(venue_address) LIKE ?",
        "%#{search_query.downcase}%", "%#{search_query.downcase}%", "%#{search_query.downcase}%"
      )
    end
    if start_date.present?
      begin
        date = Date.parse(start_date)
        count_query = count_query.where("DATE(start_time) = ?", date)
      rescue ArgumentError
      end
    end
    
    # Sort by location if coordinates provided, otherwise by start_time
    # Use database-level distance calculation for better performance
    if user_lat.present? && user_lng.present?
      # Use PostgreSQL's Haversine formula for distance calculation
      # This is much faster than loading all records and sorting in Ruby
      # Use sanitize_sql_array to safely inject parameters
      distance_sql = Tournament.sanitize_sql_array([
        "tournaments.*, 
         (6371 * acos(
           LEAST(1.0, 
             cos(radians(?)) * cos(radians(latitude)) * 
             cos(radians(longitude) - radians(?)) + 
             sin(radians(?)) * sin(radians(latitude))
           )
         )) AS distance",
        user_lat, user_lng, user_lat
      ])
      @tournaments = @tournaments
        .where.not(latitude: nil, longitude: nil)
        .select(distance_sql)
        .order("distance ASC, start_time ASC")
        .offset((page - 1) * per_page)
        .limit(per_page)
        .load
      
      # Count for has_more check
      count_query = count_query.where.not(latitude: nil, longitude: nil)
    else
      @tournaments = @tournaments
        .order(start_time: :asc)
        .offset((page - 1) * per_page)
        .limit(per_page)
        .load
    end
    
    # Check if there are more tournaments
    # Use size instead of count for better performance (uses cached count if available)
    # For filtered queries, count is needed, but we can optimize by checking has_more first
    total_count = count_query.size
    @has_more = total_count > (page * per_page)
    @current_page = page
    @per_page = per_page
    @total_count = total_count
    
    # Store filter values for form
    @selected_sport_id = sport_id
    @search_query = search_query
    @start_date = start_date
  end

  # API endpoint for infinite scroll - returns JSON
  def load_more
    @sports = Sport.cached_active
    
    # Get filter parameters
    sport_id = params[:sport_id].presence
    search_query = params[:search].presence
    start_date = params[:start_date].presence
    user_lat = params[:latitude].presence&.to_f
    user_lng = params[:longitude].presence&.to_f
    page = params[:page].to_i
    page = 1 if page < 1
    per_page = 20
    
    # Build base query with eager loading
    # Note: venue is NOT eager loaded - only accessed conditionally as fallback
    tournaments = Tournament.published
                            .active
                            .upcoming
                            .includes(:sport, :tournament_theme)
                            .preload(:image_attachment)
    
    # Apply filters
    tournaments = tournaments.where(sport_id: sport_id) if sport_id.present?
    
    if search_query.present?
      tournaments = tournaments.where(
        "LOWER(title) LIKE ? OR LOWER(description) LIKE ? OR LOWER(venue_address) LIKE ?",
        "%#{search_query.downcase}%", "%#{search_query.downcase}%", "%#{search_query.downcase}%"
      )
    end
    
    if start_date.present?
      begin
        date = Date.parse(start_date)
        tournaments = tournaments.where("DATE(start_time) = ?", date)
      rescue ArgumentError
      end
    end
    
    # Build count query
    count_query = Tournament.published.active.upcoming
    count_query = count_query.where(sport_id: sport_id) if sport_id.present?
    if search_query.present?
      count_query = count_query.where(
        "LOWER(title) LIKE ? OR LOWER(description) LIKE ? OR LOWER(venue_address) LIKE ?",
        "%#{search_query.downcase}%", "%#{search_query.downcase}%", "%#{search_query.downcase}%"
      )
    end
    if start_date.present?
      begin
        date = Date.parse(start_date)
        count_query = count_query.where("DATE(start_time) = ?", date)
      rescue ArgumentError
      end
    end
    
    # Apply sorting and pagination
    if user_lat.present? && user_lng.present?
      distance_sql = Tournament.sanitize_sql_array([
        "tournaments.*, 
         (6371 * acos(
           LEAST(1.0, 
             cos(radians(?)) * cos(radians(latitude)) * 
             cos(radians(longitude) - radians(?)) + 
             sin(radians(?)) * sin(radians(latitude))
           )
         )) AS distance",
        user_lat, user_lng, user_lat
      ])
      tournaments = tournaments
        .where.not(latitude: nil, longitude: nil)
        .select(distance_sql)
        .order("distance ASC, start_time ASC")
        .offset((page - 1) * per_page)
        .limit(per_page)
        .load
      
      count_query = count_query.where.not(latitude: nil, longitude: nil)
    else
      tournaments = tournaments
        .order(start_time: :asc)
        .offset((page - 1) * per_page)
        .limit(per_page)
        .load
    end
    
    total_count = count_query.count
    has_more = total_count > (page * per_page)
    
    # Render JSON response
    render json: {
      success: true,
      tournaments: tournaments.map do |tournament|
        {
          id: tournament.id,
          title: tournament.title,
          slug: tournament.slug,
          description: tournament.description,
          start_time: tournament.start_time.iso8601,
          venue_address: tournament.venue_address,
          venue_name: tournament.venue&.name,
          entry_fee: tournament.entry_fee&.to_f,
          first_prize: tournament.first_prize&.to_f,
          sport: {
            id: tournament.sport.id,
            name: tournament.sport.name,
            icon: tournament.sport.icon
          },
          tournament_theme: tournament.tournament_theme ? {
            id: tournament.tournament_theme.id,
            name: tournament.tournament_theme.name,
            preview_image_url: tournament.tournament_theme.preview_image_url
          } : nil,
          image_url: tournament.image.attached? ? url_for(tournament.image) : nil,
          likes_count: tournament.likes_count || 0,
          distance: tournament.respond_to?(:distance) ? tournament.distance&.round(1) : nil,
          venue_google_maps_link: tournament.venue_google_maps_link.presence || tournament.venue&.google_maps_link
        }
      end,
      has_more: has_more,
      current_page: page,
      total_count: total_count
    }
  end
end

