module PatchImporters
  class MarvelRivalsImporter
    Result = Struct.new(:imported, :skipped, keyword_init: true)

    def call
      game = Game.find_by(slug: "marvel-rivals")
      raise ActiveRecord::RecordNotFound, "Marvel Rivals game not found" if game.nil?

      results = Scrapers::MarvelRivalsScraper.new.call
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
          content: data[:content],
          published_at: data[:published_at] || patch.published_at
        )
      end

      Result.new(imported: imported, skipped: skipped)
    end
  end
end
