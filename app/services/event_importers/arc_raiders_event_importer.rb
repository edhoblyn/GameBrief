module EventImporters
  class ArcRaidersEventImporter
    Result = Struct.new(:imported, :skipped, keyword_init: true)

    GAME_SLUGS = ["arc-raiders"].freeze
    GAME_NAMES = ["ARC Raiders", "Arc Raiders"].freeze

    def call(replace: false)
      game = find_game
      raise ActiveRecord::RecordNotFound, "ARC Raiders game not found" if game.nil?

      # Scraper runs first — if it raises, nothing in the DB is touched
      all_results = EventScrapers::ArcRaidersEventScraper.new.call
      results = all_results.select { |e| e[:start_date].nil? || e[:start_date] >= Date.today }

      # When replacing, always clear stale events (scraper ran cleanly)
      game.events.destroy_all if replace

      return Result.new(imported: 0, skipped: 0) if results.empty?

      imported = 0
      skipped  = 0

      results.each do |data|
        event = game.events.find_or_initialize_by(title: data[:title])
        if event.new_record?
          event.update!(description: data[:description], start_date: data[:start_date])
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
