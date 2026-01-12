class Api::V1::TeamsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    teams = Team.active
    teams = teams.where(sport_id: params[:sport_id]) if params[:sport_id].present?
    teams = teams.limit(params[:limit] || 20)
    
    render_success(teams.map { |t| serialize_team(t) })
  end

  def show
    team = Team.find_by!(slug: params[:id])
    render_success(serialize_team(team, detailed: true))
  end

  def create
    team = current_user.teams_as_captain.build(team_params)
    team.sport_id = params[:sport_id] || team_params[:sport_id]
    
    if team.save
      team.team_members.create(user: current_user, role: 'captain', is_active: true)
      render_success(serialize_team(team, detailed: true), :created)
    else
      render_error(team.errors.full_messages.join(', '))
    end
  end

  def update
    team = current_user.teams_as_captain.find_by!(slug: params[:id])
    
    if team.update(team_params)
      render_success(serialize_team(team, detailed: true))
    else
      render_error(team.errors.full_messages.join(', '))
    end
  end

  def destroy
    team = current_user.teams_as_captain.find_by!(slug: params[:id])
    team.update(is_active: false)
    render_success({ message: 'Team deleted successfully' })
  end

  private

  def team_params
    params.require(:team).permit(:name, :description, :sport_id, logo: [])
  end

  def serialize_team(team, detailed: false)
    data = {
      id: team.id,
      name: team.name,
      slug: team.slug,
      description: team.description,
      member_count: team.member_count,
      sport: {
        id: team.sport.id,
        name: team.sport.name
      },
      captain: {
        id: team.captain.id,
        name: team.captain.name
      }
    }

    if detailed
      data[:members] = team.members.map { |m| { id: m.id, name: m.name } }
    end

    data
  end
end

