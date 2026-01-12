class CleanupExpiredTournamentsJob < ApplicationJob
  queue_as :default

  def perform
    expired_tournaments = Tournament.where('start_time < ? AND tournament_status IN (?)', 
                                           Time.current, ['draft', 'published'])
    
    expired_tournaments.find_each do |tournament|
      tournament.update(tournament_status: 'completed')
    end

    Rails.logger.info "Cleaned up #{expired_tournaments.count} expired tournaments"
  end
end
