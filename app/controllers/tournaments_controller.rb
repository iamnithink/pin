class TournamentsController < ApplicationController
  include TournamentThemeHelper

  def show
    @tournament = Tournament.friendly.find(params[:slug])
    @tournament.increment_view_count unless @tournament.view_count_changed?
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Tournament not found'
  end
end
