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
end
