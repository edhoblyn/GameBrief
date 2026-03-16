class UpdateGrandTheftAutoVToGta5Online < ActiveRecord::Migration[8.1]
  class MigrationGame < ApplicationRecord
    self.table_name = "games"
  end

  class MigrationPatch < ApplicationRecord
    self.table_name = "patches"
  end

  class MigrationEvent < ApplicationRecord
    self.table_name = "events"
  end

  class MigrationFavourite < ApplicationRecord
    self.table_name = "favourites"
  end

  TARGET_NAME = "GTA 5: Online".freeze
  TARGET_SLUG = "gta-5-online".freeze
  LEGACY_NAMES = ["Grand Theft Auto V", "GTA 5"].freeze

  def up
    legacy_game = MigrationGame.where("LOWER(name) IN (?)", LEGACY_NAMES.map(&:downcase)).order(:id).first
    target_game = MigrationGame.find_by("LOWER(name) = ? OR slug = ?", TARGET_NAME.downcase, TARGET_SLUG)

    if legacy_game && target_game && legacy_game.id != target_game.id
      reassign_associations(from: legacy_game, to: target_game)
      legacy_game.destroy!
      legacy_game = target_game
    end

    game = target_game || legacy_game
    return unless game

    game.update!(
      name: TARGET_NAME,
      slug: TARGET_SLUG,
      free_to_play: false,
      single_player: false,
      multiplayer: true
    )
  end

  def down
    game = MigrationGame.find_by("LOWER(name) = ? OR slug = ?", TARGET_NAME.downcase, TARGET_SLUG)
    return unless game

    game.update!(
      name: "Grand Theft Auto V",
      slug: "grand-theft-auto-v",
      free_to_play: false,
      single_player: true,
      multiplayer: true
    )
  end

  private

  def reassign_associations(from:, to:)
    MigrationPatch.where(game_id: from.id).update_all(game_id: to.id)
    MigrationEvent.where(game_id: from.id).update_all(game_id: to.id)
    MigrationFavourite.where(game_id: from.id).update_all(game_id: to.id)
  end
end
