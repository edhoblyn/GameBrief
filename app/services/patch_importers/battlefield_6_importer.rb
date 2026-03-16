module PatchImporters
  class Battlefield6Importer
    Result = Struct.new(:imported, :skipped, keyword_init: true)

    GAME_SLUGS = [
      "battlefield-6"
    ].freeze

    GAME_NAMES = [
      "Battlefield 6"
    ].freeze

    def call
      game = find_game
      raise ActiveRecord::RecordNotFound, "Battlefield 6 game not found" if game.nil?

      results = Scrapers::Battlefield6Scraper.new.call
      imported = 0
      skipped = 0

      results.each do |data|
        patch = Patch.find_or_initialize_by(source_url: data[:source_url])

        if patch.new_record?
          imported += 1
        else
          skipped += 1
        end

        patch.update!(Patch.import_attributes(data, game: game, existing_patch: patch))
      end

      cleanup_placeholder_patches(game) if results.any?

      Result.new(imported: imported, skipped: skipped)
    end

    private

    def find_game
      Game.find_by(slug: GAME_SLUGS) ||
        Game.where("LOWER(name) IN (?)", GAME_NAMES.map(&:downcase)).order(:id).first
    end

    def cleanup_placeholder_patches(game)
      game.patches.where(source_url: nil).destroy_all
    end
  end
end
