module EventImporters
  class ValorantEventImporter
    Result = Struct.new(:imported, :skipped, keyword_init: true)

    GAME_SLUGS = ["valorant"].freeze
    GAME_NAMES = ["Valorant", "VALORANT"].freeze

    # Imports real Valorant events scraped from vlr.gg / playvalorant.com.
    #
    # replace: true  — destroys all existing events for the game first,
    #                   then creates fresh ones from real data.
    #                   Only destroys if the scraper returns at least one event.
    # replace: false — upsert: creates new events, skips ones already present
    #                   (matched by title).
    def call(replace: false)
      game = find_game
      raise ActiveRecord::RecordNotFound, "Valorant game not found" if game.nil?

      results = EventScrapers::ValorantEventScraper.new.call
                                                         .select { |e| e[:start_date].nil? || e[:start_date] >= Date.today }
      return Result.new(imported: 0, skipped: 0) if results.empty?

      game.events.destroy_all if replace

      imported = 0
      skipped  = 0

      results.each do |data|
        event = game.events.find_or_initialize_by(title: data[:title])
        if event.new_record?
          event.update!(
            description: data[:description],
            start_date:  data[:start_date]
          )
          imported += 1
        else
          skipped += 1
        end
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
