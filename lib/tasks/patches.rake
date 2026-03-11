namespace :patches do
  desc "Scrape and import Marvel Rivals patch notes from marvelrivals.com"
  task scrape_marvel_rivals: :environment do
    game = Game.find_by(slug: "marvel-rivals")

    if game.nil?
      puts "ERROR: Marvel Rivals game not found in the database."
      puts "Run: Game.create!(name: 'Marvel Rivals', slug: 'marvel-rivals', genre: ['shooter'])"
      exit 1
    end

    puts "Scraping Marvel Rivals patch notes..."
    results = Scrapers::MarvelRivalsScraper.new.call

    if results.empty?
      puts "No patches found. The site structure may have changed."
      exit 0
    end

    imported = 0
    skipped  = 0

    results.each do |data|
      patch = Patch.find_or_initialize_by(source_url: data[:source_url])

      if patch.new_record?
        patch.assign_attributes(title: data[:title], content: data[:content], game: game)
        patch.save!
        puts "  Imported: #{data[:title]}"
        imported += 1
      else
        skipped += 1
      end
    end

    puts "Done — #{imported} imported, #{skipped} already existed."
  end
end
