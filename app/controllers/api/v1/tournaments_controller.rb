class Api::V1::TournamentsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:index, :show, :nearby, :by_pincode]

  def index
    tournaments = Tournament.discovery(
      sport_id: params[:sport_id],
      pincode: params[:pincode],
      status: params[:status] || 'published'
    ).limit(params[:limit] || 20)

    render_success(tournaments.map { |t| serialize_tournament(t) })
  end

  def show
    tournament = Tournament.find_by!(slug: params[:id])
    render_success(serialize_tournament(tournament, detailed: true))
  end

  def create
    tournament = current_user.created_tournaments.build(tournament_params)
    
    if tournament.save
      render_success(serialize_tournament(tournament, detailed: true), :created)
    else
      render_error(tournament.errors.full_messages.join(', '))
    end
  end

  def update
    tournament = current_user.created_tournaments.find_by!(slug: params[:id])
    
    if tournament.update(tournament_params)
      render_success(serialize_tournament(tournament, detailed: true))
    else
      render_error(tournament.errors.full_messages.join(', '))
    end
  end

  def destroy
    tournament = current_user.created_tournaments.find_by!(slug: params[:id])
    tournament.update(is_active: false)
    render_success({ message: 'Tournament deleted successfully' })
  end

  def nearby
    lat = params[:latitude].to_f
    lng = params[:longitude].to_f
    radius = params[:radius]&.to_f || 10

    tournaments = Tournament.published
                   .nearby(lat, lng, radius)
                   .upcoming
                   .limit(params[:limit] || 20)

    render_success(tournaments.map { |t| serialize_tournament(t) })
  end

  def by_pincode
    pincode = params[:pincode]
    tournaments = Tournament.discovery(pincode: pincode).limit(params[:limit] || 20)
    render_success(tournaments.map { |t| serialize_tournament(t) })
  end

  def publish
    tournament = current_user.created_tournaments.find_by!(slug: params[:id])
    
    if tournament.publish!
      render_success(serialize_tournament(tournament, detailed: true))
    else
      render_error(tournament.errors.full_messages.join(', '))
    end
  end

  private

  def tournament_params
    params.require(:tournament).permit(
      :title, :description, :sport_id, :cricket_match_type_id,
      :venue_id, :start_time, :end_time,
      :max_players_per_team, :min_players_per_team, :entry_fee,
      :pincode, :tournament_theme_id, image: [], team_ids: []
    )
  end

  def serialize_tournament(tournament, detailed: false)
    data = {
      id: tournament.id,
      title: tournament.title,
      slug: tournament.slug,
      description: tournament.description,
      start_time: tournament.start_time,
      end_time: tournament.end_time,
      tournament_status: tournament.tournament_status,
      entry_fee: tournament.entry_fee,
      view_count: tournament.view_count,
      join_count: tournament.join_count,
      sport: {
        id: tournament.sport.id,
        name: tournament.sport.name,
        slug: tournament.sport.slug
      },
      venue: {
        id: tournament.venue.id,
        name: tournament.venue.name,
        address: tournament.venue.address,
        pincode: tournament.venue.pincode,
        google_maps_url: tournament.google_maps_url
      },
      created_by: {
        id: tournament.created_by.id,
        name: tournament.created_by.name
      }
    }

    if tournament.cricket_match_type.present?
      data[:cricket_match_type] = {
        id: tournament.cricket_match_type.id,
        name: tournament.cricket_match_type.name,
        team_size: tournament.cricket_match_type.team_size,
        category: tournament.cricket_match_type.category
      }
    end

    if tournament.image.attached?
      data[:image_url] = Rails.application.routes.url_helpers.rails_blob_path(tournament.image, only_path: true)
    elsif tournament.tournament_theme.present?
      data[:theme] = {
        id: tournament.tournament_theme.id,
        name: tournament.tournament_theme.name,
        preview_image_url: tournament.tournament_theme.preview_image_url,
        color_scheme: tournament.tournament_theme.color_scheme
      }
    end

    if detailed
      data[:participants] = tournament.participants.map { |p| { id: p.id, name: p.name } }
      data[:teams] = tournament.teams.map { |t| { id: t.id, name: t.name, is_default: t.is_default? } }
      data[:can_join] = current_user ? tournament.can_join?(current_user) : false
    end

    data
  end
end
