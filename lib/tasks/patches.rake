namespace :patches do
  def run_scrape(source, continue_on_error: false)
    config = PatchScrapeRunner.fetch(source)

    puts "Scraping #{config[:label]} patch notes..."
    result = PatchScrapeRunner.run(source)
    puts "Done - #{result.imported} imported, #{result.skipped} already existed."
    result
  rescue ActiveRecord::RecordNotFound
    puts "ERROR: #{config[:missing_game_error]}"
    puts config[:missing_game_hint]
    exit 1 unless continue_on_error
    nil
  rescue StandardError => e
    puts "ERROR: #{config[:label]} scrape failed: #{e.class}: #{e.message}"
    raise unless continue_on_error
    nil
  end

  desc "Scrape and import Marvel Rivals patch notes from marvelrivals.com"
  task scrape_marvel_rivals: :environment do
    run_scrape("marvel_rivals")
  end

  desc "Scrape and import Call of Duty: Warzone patch notes from callofduty.com"
  task scrape_warzone: :environment do
    run_scrape("warzone")
  end

  desc "Scrape and import Fortnite patch notes from fortnite.com"
  task scrape_fortnite: :environment do
    run_scrape("fortnite")
  end

  desc "Scrape and import Apex Legends patch notes from ea.com"
  task scrape_apex_legends: :environment do
    run_scrape("apex_legends")
  end

  desc "Scrape and import EA Sports FC 26 pitch notes from ea.com"
  task scrape_ea_sports_fc_26: :environment do
    run_scrape("ea_sports_fc_26")
  end

  desc "Scrape and import Helldivers 2 patch notes from arrowhead.zendesk.com"
  task scrape_helldivers_2: :environment do
    run_scrape("helldivers_2")
  end

  desc "Scrape and import Destiny 2 patch notes from bungie.net"
  task scrape_destiny_2: :environment do
    run_scrape("destiny_2")
  end

  desc "Scrape and import Minecraft patch notes from feedback.minecraft.net"
  task scrape_minecraft: :environment do
    run_scrape("minecraft")
  end

  desc "Scrape and import VALORANT patch notes from playvalorant.com"
  task scrape_valorant: :environment do
    run_scrape("valorant")
  end

  desc "Scrape and import Roblox release notes from create.roblox.com"
  task scrape_roblox: :environment do
    run_scrape("roblox")
  end

  desc "Scrape and import Clash Royale release notes from supercell.com"
  task scrape_clash_royale: :environment do
    run_scrape("clash_royale")
  end

  desc "Scrape and import Clash of Clans release notes from supercell.com"
  task scrape_clash_of_clans: :environment do
    run_scrape("clash_of_clans")
  end

  desc "Scrape and import patch notes for all configured games"
  task scrape_all: :environment do
    failures = []

    PatchScrapeRunner.sources.each do |source|
      result = run_scrape(source, continue_on_error: true)
      failures << source if result.nil?
    end

    if failures.any?
      puts
      puts "Completed with failures for: #{failures.join(', ')}"
    else
      puts
      puts "Completed successfully for all sources."
    end
  end
end
