class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  validates :user_id, uniqueness: { scope: :friend_id }
  validate :cannot_befriend_self

  private

  def cannot_befriend_self
    errors.add(:user, "cannot be friends with yourself") if user_id == friend_id
  end
end
