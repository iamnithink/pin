class Ability
  include CanCan::Ability

  def initialize(user)
    # Guest users (not signed in) - allow public access
    unless user
      can :read, :home
      can :read, Tournament, tournament_status: 'published'
      can :read, Sport
      can :read, Venue
      return
    end

    case user.role
    when 'super_admin'
      # Super Admin: Full access to everything
      can :manage, :all
      
    when 'admin'
      # Admin: Access to teams, tournaments, venues
      can :manage, Team
      can :manage, Tournament
      can [:like, :unlike], Tournament
      can :manage, Venue
      can :read, Sport
      can :read, CricketMatchType
      can :read, TournamentTheme
      can :read, User
      can :update, User, id: user.id  # Can update own profile
      # Admin can manage all comments
      can :manage, Comment
      
    when 'user'
      # User: Access to own tournaments, homepage
      can :read, :home
      
      # Can manage own tournaments
      can :manage, Tournament, created_by_id: user.id
      
      # Can view published tournaments
      can :read, Tournament, tournament_status: 'published'
      
      # Can like/unlike tournaments
      can [:like, :unlike], Tournament
      
      # Can view own profile
      can :read, User, id: user.id
      can :update, User, id: user.id
      
      # Can view sports, venues (read-only)
      can :read, Sport
      can :read, Venue
      
      # Can view teams (read-only)
      can :read, Team
      
      # Comments: Can create comments on published tournaments
      can :create, Comment, tournament: { tournament_status: 'published' }
      # Can read comments on published tournaments
      can :read, Comment, tournament: { tournament_status: 'published' }
      # Can update/delete own comments
      can [:update, :destroy], Comment, user_id: user.id
      
    else
      # Unknown role - no access
      cannot :manage, :all
    end
  end
end
