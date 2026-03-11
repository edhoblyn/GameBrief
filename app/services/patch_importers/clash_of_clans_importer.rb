module PatchImporters
  class ClashOfClansImporter
    Result = Struct.new(:imported, :skipped, keyword_init: true)

    GAME_SLUGS = [
      "clash-of-clans"
    ].freeze

    GAME_NAMES = [
      "Clash of Clans"
    ].freeze

    def call
      game = find_game
      raise ActiveRecord::RecordNotFound, "Clash of Clans game not found" if game.nil?

      results = Scrapers::ClashOfClansScraper.new.call
      imported = 0
      skipped = 0

      results.each do |data|
        patch = Patch.find_or_initialize_by(source_url: data[:source_url])

        if patch.new_record?
          imported += 1
        else
          skipped += 1
        end

        patch.update!(
          game: game,
          title: data[:title],
          content: data[:content]
        )
      end

      Result.new(imported: imported, skipped: skipped)
    end

    private

    def find_game
      Game.find_by(slug: GAME_SLUGS) ||
        Game.where("LOWER(name) IN (?)", GAME_NAMES.map(&:downcase)).order(:id).first
    end
  end
end
