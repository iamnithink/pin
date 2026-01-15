class TournamentsController < ApplicationController
  include TournamentThemeHelper
  before_action :set_tournament, only: [:show, :like, :unlike]

  def show
    authorize! :read, @tournament
    @tournament.increment_view_count unless @tournament.view_count_changed?
    @is_liked = user_signed_in? && @tournament.tournament_likes.exists?(user_id: current_user.id)
    # Safely get likes count - handle case where counter cache column doesn't exist
    @like_count = begin
      if @tournament.respond_to?(:likes_count) && @tournament.attributes.key?('likes_count')
        @tournament.likes_count || 0
      elsif @tournament.respond_to?(:tournament_likes)
        @tournament.tournament_likes.count
      else
        0
      end
    rescue => e
      0
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Tournament not found'
  end

  def like
    unless user_signed_in?
      render json: { success: false, message: 'Please sign in to like tournaments', redirect: new_user_session_path(locale: I18n.locale) }, status: :unauthorized
      return
    end
    
    authorize! :like, @tournament
    
    if @tournament.tournament_likes.exists?(user_id: current_user.id)
      render json: { success: false, message: 'Already liked' }, status: :unprocessable_entity
    else
      @tournament.tournament_likes.create(user: current_user)
      @tournament.reload
      like_count = begin
        if @tournament.respond_to?(:likes_count) && @tournament.attributes.key?('likes_count')
          @tournament.likes_count || 0
        elsif @tournament.respond_to?(:tournament_likes)
          @tournament.tournament_likes.count
        else
          0
        end
      rescue => e
        0
      end
      render json: { success: true, like_count: like_count }
    end
  end

  def unlike
    unless user_signed_in?
      render json: { success: false, message: 'Please sign in', redirect: new_user_session_path(locale: I18n.locale) }, status: :unauthorized
      return
    end
    
    authorize! :unlike, @tournament
    
    like = @tournament.tournament_likes.find_by(user_id: current_user.id)
    if like
      like.destroy
      @tournament.reload
      like_count = begin
        if @tournament.respond_to?(:likes_count) && @tournament.attributes.key?('likes_count')
          @tournament.likes_count || 0
        elsif @tournament.respond_to?(:tournament_likes)
          @tournament.tournament_likes.count
        else
          0
        end
      rescue => e
        0
      end
      render json: { success: true, like_count: like_count }
    else
      render json: { success: false, message: 'Not liked' }, status: :unprocessable_entity
    end
  end

  private

  def set_tournament
    # Eager load all associations used in the show view to avoid N+1 queries
    # Note: tournament_likes uses counter_cache (likes_count), so no need to eager load
    # venue is NOT eager loaded - view uses venue_name column first, only falls back to venue&.name
    # when venue_name is blank (rare case), so lazy loading is acceptable
    # created_by is not used in the view, so don't eager load it
    # image_attachment is preloaded to avoid N+1 when checking image.attached?
    # blob is NOT preloaded - ActiveStorage handles url_for() efficiently without eager loading blob
    @tournament = Tournament.includes(
      :sport, 
      :tournament_theme, 
      :cricket_match_type
    )
    .preload(:image_attachment)
    .friendly.find(params[:slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Tournament not found'
  end
end
