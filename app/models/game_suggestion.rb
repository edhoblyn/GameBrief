class GameSuggestion < ApplicationRecord
  before_validation :normalize_name

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }, uniqueness: { case_sensitive: false }
  validate :name_looks_like_game_title
  validate :name_is_not_already_listed

  private

  def normalize_name
    self.name = name.to_s.squish.presence
  end

  def name_looks_like_game_title
    return if name.blank?

    if name.match?(/\A(add|please add|can you add|could you add|i want|want|fix|help)\b/i)
      errors.add(:name, "must be the game title only")
    end

    if name.match?(%r{https?://|www\.|@}i)
      errors.add(:name, "must be a game title, not a link or email")
    end

    unless name.match?(/[[:alpha:]]/)
      errors.add(:name, "must include letters")
    end

    unless name.match?(/\A[\p{L}\p{N}\s:'&!.,+\-\/()]+\z/u)
      errors.add(:name, "contains unsupported characters")
    end
  end

  def name_is_not_already_listed
    return if name.blank?
    return unless Game.where("LOWER(name) = ?", name.downcase).exists?

    errors.add(:name, "is already listed on GameBrief")
  end
end
