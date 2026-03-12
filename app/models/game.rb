class Game < ApplicationRecord
  has_many :favourites, dependent: :destroy
  has_many :fans, through: :favourites, source: :user
  has_many :events, dependent: :destroy
  has_many :patches, dependent: :destroy

  scope :search_by_name, ->(query) { query.present? ? where("name ILIKE ?", "%#{query}%") : all }
  scope :with_genre, ->(genre) { genre.present? ? where("? = ANY(genre::text[])", genre) : all }
  scope :free_to_play_only, ->(free_to_play) { free_to_play == "true" ? where(free_to_play: true) : all }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, uniqueness: true, allow_blank: true
end
