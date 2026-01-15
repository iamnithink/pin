class TournamentLike < ApplicationRecord
  belongs_to :user
  belongs_to :tournament, counter_cache: :likes_count

  validates :user_id, uniqueness: { scope: :tournament_id, message: "has already liked this tournament" }
end
