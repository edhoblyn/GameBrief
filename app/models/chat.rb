class Chat < ApplicationRecord
  belongs_to :patch
  belongs_to :user
  has_many :messages, dependent: :destroy

  validates :patch, presence: true
  validates :user, presence: true

  def generate_title_from_first_message
    first = messages.where(role: "user").first
    return unless first && title.blank?
    update(title: first.content.truncate(60))
  end
end
