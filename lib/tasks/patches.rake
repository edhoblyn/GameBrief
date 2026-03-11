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

  desc "Scrape and import Apex Legends patch notes from ea.com"
  task scrape_apex_legends: :environment do
    puts "Scraping Apex Legends patch notes..."
    result = PatchImporters::ApexLegendsImporter.new.call
    puts "Done - #{result.imported} imported, #{result.skipped} already existed."
  rescue ActiveRecord::RecordNotFound
    puts "ERROR: Apex Legends game not found in the database."
    puts "Expected an existing Game named 'Apex Legends' or slugged 'apex-legends'."
    exit 1
  end

  desc "Scrape and import Helldivers 2 patch notes from arrowhead.zendesk.com"
  task scrape_helldivers_2: :environment do
    puts "Scraping Helldivers 2 patch notes..."
    result = PatchImporters::Helldivers2Importer.new.call
    puts "Done - #{result.imported} imported, #{result.skipped} already existed."
  rescue ActiveRecord::RecordNotFound
    puts "ERROR: Helldivers 2 game not found in the database."
    puts "Expected an existing Game named 'Helldivers 2' or slugged 'helldivers-2'."
    exit 1
  end

  desc "Scrape and import Destiny 2 patch notes from bungie.net"
  task scrape_destiny_2: :environment do
    puts "Scraping Destiny 2 patch notes..."
    result = PatchImporters::Destiny2Importer.new.call
    puts "Done - #{result.imported} imported, #{result.skipped} already existed."
  rescue ActiveRecord::RecordNotFound
    puts "ERROR: Destiny 2 game not found in the database."
    puts "Expected an existing Game named 'Destiny 2' or slugged 'destiny-2'."
    exit 1
  end

  desc "Scrape and import Minecraft patch notes from feedback.minecraft.net"
  task scrape_minecraft: :environment do
    puts "Scraping Minecraft patch notes..."
    result = PatchImporters::MinecraftImporter.new.call
    puts "Done - #{result.imported} imported, #{result.skipped} already existed."
  rescue ActiveRecord::RecordNotFound
    puts "ERROR: Minecraft game not found in the database."
    puts "Expected an existing Game named 'Minecraft' or slugged 'minecraft'."
    exit 1
  end
end
