namespace :patches do
  desc "Scrape and import Marvel Rivals patch notes from marvelrivals.com"
  task scrape_marvel_rivals: :environment do
    puts "Scraping Marvel Rivals patch notes..."
    result = PatchImporters::MarvelRivalsImporter.new.call
    puts "Done - #{result.imported} imported, #{result.skipped} already existed."
  rescue ActiveRecord::RecordNotFound
    puts "ERROR: Marvel Rivals game not found in the database."
    puts "Run: Game.create!(name: 'Marvel Rivals', slug: 'marvel-rivals', genre: ['shooter'])"
    exit 1
  end

  desc "Scrape and import Call of Duty: Warzone patch notes from callofduty.com"
  task scrape_warzone: :environment do
    puts "Scraping Call of Duty: Warzone patch notes..."
    result = PatchImporters::WarzoneImporter.new.call
    puts "Done - #{result.imported} imported, #{result.skipped} already existed."
  rescue ActiveRecord::RecordNotFound
    puts "ERROR: Warzone game not found in the database."
    puts "Expected an existing Game named 'Call of Duty: Warzone' or slugged 'call-of-duty-warzone'."
    exit 1
  end

  desc "Scrape and import Fortnite patch notes from fortnite.com"
  task scrape_fortnite: :environment do
    puts "Scraping Fortnite patch notes..."
    result = PatchImporters::FortniteImporter.new.call
    puts "Done - #{result.imported} imported, #{result.skipped} already existed."
  rescue ActiveRecord::RecordNotFound
    puts "ERROR: Fortnite game not found in the database."
    puts "Expected an existing Game named 'Fortnite' or slugged 'fortnite'."
    exit 1
  end
end
