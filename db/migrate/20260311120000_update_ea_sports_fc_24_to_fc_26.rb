class UpdateEaSportsFc24ToFc26 < ActiveRecord::Migration[8.1]
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

  def up
    old_game = MigrationGame.find_by("LOWER(name) = ?", "ea sports fc 24")
    return unless old_game

    new_game = MigrationGame.find_by("LOWER(name) = ?", "ea sports fc 26")

    if new_game
      MigrationPatch.where(game_id: old_game.id).update_all(game_id: new_game.id)
      MigrationEvent.where(game_id: old_game.id).update_all(game_id: new_game.id)
      MigrationFavourite.where(game_id: old_game.id).update_all(game_id: new_game.id)
      old_game.destroy!
    else
      new_slug = old_game.slug&.sub(/24\z/, "26") || "ea-sports-fc-26"
      old_game.update!(name: "EA Sports FC 26", slug: new_slug)
    end
  end

  def down
    game = MigrationGame.find_by("LOWER(name) = ?", "ea sports fc 26")
    return unless game

    old_slug = game.slug&.sub(/26\z/, "24") || "ea-sports-fc-24"
    game.update!(name: "EA Sports FC 24", slug: old_slug)
  end
end
