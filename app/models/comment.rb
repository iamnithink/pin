class Comment < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :tournament
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id', dependent: :destroy

  # Validations
  validates :body, presence: true, length: { minimum: 1, maximum: 5000 }
  validates :user_id, presence: true
  validates :tournament_id, presence: true
  validate :parent_belongs_to_same_tournament, if: -> { parent_id.present? }
  validate :parent_is_not_reply, if: -> { parent_id.present? }

  # Scopes
  scope :top_level, -> { where(parent_id: nil) }
  scope :replies, -> { where.not(parent_id: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }

  # Callbacks
  after_create :increment_tournament_comments_count
  after_destroy :decrement_tournament_comments_count

  def is_reply?
    parent_id.present?
  end

  def is_top_level?
    parent_id.nil?
  end

  def can_be_edited_by?(user)
    return false unless user.present?
    user.id == user_id || user.admin? || user.super_admin?
  end

  def can_be_deleted_by?(user)
    return false unless user.present?
    user.id == user_id || user.admin? || user.super_admin?
  end

  private

  def parent_belongs_to_same_tournament
    return unless parent.present?
    errors.add(:parent_id, 'must belong to the same tournament') unless parent.tournament_id == tournament_id
  end

  def parent_is_not_reply
    return unless parent.present?
    errors.add(:parent_id, 'cannot reply to a reply') if parent.is_reply?
  end

  def increment_tournament_comments_count
    return unless is_top_level?
    tournament.increment!(:comments_count) if tournament.respond_to?(:comments_count)
  end

  def decrement_tournament_comments_count
    return unless is_top_level?
    tournament.decrement!(:comments_count) if tournament.respond_to?(:comments_count)
  end
end
