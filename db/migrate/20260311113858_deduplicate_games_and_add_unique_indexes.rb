class DeduplicateGamesAndAddUniqueIndexes < ActiveRecord::Migration[8.1]
  class MigrationGame < ApplicationRecord
    self.table_name = "games"
  end

  class MigrationFavourite < ApplicationRecord
    self.table_name = "favourites"
  end

  class MigrationEvent < ApplicationRecord
    self.table_name = "events"
  end

  class MigrationPatch < ApplicationRecord
    self.table_name = "patches"
  end

  def up
    deduplicate_by_slug
    deduplicate_by_name

    add_index :games, :slug, unique: true
    add_index :games, "LOWER(name)", unique: true, name: "index_games_on_lower_name"
  end

  def down
    remove_index :games, name: "index_games_on_lower_name"
    remove_index :games, :slug
  end

  private

  def deduplicate_by_slug
    duplicate_slugs = execute(<<~SQL).to_a
      SELECT slug
      FROM games
      WHERE slug IS NOT NULL AND slug <> ''
      GROUP BY slug
      HAVING COUNT(*) > 1
    SQL

    duplicate_slugs.each do |row|
      merge_duplicates(MigrationGame.where(slug: row["slug"]).order(:id))
    end
  end

  def deduplicate_by_name
    duplicate_names = execute(<<~SQL).to_a
      SELECT LOWER(name) AS normalized_name
      FROM games
      WHERE name IS NOT NULL AND name <> ''
      GROUP BY LOWER(name)
      HAVING COUNT(*) > 1
    SQL

    duplicate_names.each do |row|
      scope = MigrationGame.where("LOWER(name) = ?", row["normalized_name"]).order(:id)
      merge_duplicates(scope)
    end
  end

  def merge_duplicates(scope)
    games = scope.to_a
    return if games.size < 2

    keeper = games.shift

    games.each do |duplicate|
      MigrationFavourite.where(game_id: duplicate.id).update_all(game_id: keeper.id)
      MigrationEvent.where(game_id: duplicate.id).update_all(game_id: keeper.id)
      MigrationPatch.where(game_id: duplicate.id).update_all(game_id: keeper.id)

      keeper.update_columns(
        slug: keeper.slug.presence || duplicate.slug,
        cover_image: keeper.cover_image.presence || duplicate.cover_image,
        updated_at: Time.current
      )

      duplicate.destroy!
    end
  end
end
