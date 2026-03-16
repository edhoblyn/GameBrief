class Game < ApplicationRecord
  has_many :favourites, dependent: :destroy
  has_many :fans, through: :favourites, source: :user
  has_many :events, dependent: :destroy
  has_many :patches, dependent: :destroy

  scope :search_by_name, ->(query) { query.present? ? where("name ILIKE ?", "%#{query}%") : all }
  scope :with_genre, ->(genre) { genre.present? ? where("? = ANY(genre::text[])", genre) : all }
  scope :free_to_play_only, ->(free_to_play) { free_to_play == "true" ? where(free_to_play: true) : all }
  scope :single_player_only, ->(single_player) { single_player == "true" ? where(single_player: true) : all }
  scope :multiplayer_only, ->(multiplayer) { multiplayer == "true" ? where(multiplayer: true) : all }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, uniqueness: true, allow_blank: true

  def genre_tags
    raw_value = self[:genre]

    case raw_value
    when Array
      raw_value.filter_map { |value| value.to_s.strip.presence }
    when String
      parse_genre_string(raw_value)
    else
      []
    end
  end

  private

  def parse_genre_string(value)
    cleaned = value.strip
    return [] if cleaned.blank?

    if cleaned.start_with?("{") && cleaned.end_with?("}")
      cleaned[1...-1]
        .split(",")
        .filter_map { |entry| entry.delete_prefix('"').delete_suffix('"').strip.presence }
    else
      cleaned.split(",").filter_map { |entry| entry.strip.presence }
    end
  end
end
