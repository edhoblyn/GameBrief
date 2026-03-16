namespace :patches do
  def run_scrape(source, continue_on_error: false)
    config = PatchScrapeRunner.fetch(source)

    unless PatchScrapeRunner.scrapeable?(source)
      puts "SKIPPED: #{config[:disabled_message] || "#{config[:label]} currently requires an API or alternate endpoint."}"
      return nil
    end

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

  desc "Scrape and import ARC Raiders patch notes from arcraiders.com"
  task scrape_arc_raiders: :environment do
    run_scrape("arc_raiders")
  end

  desc "Scrape and import Battlefield 6 updates from ea.com"
  task scrape_battlefield_6: :environment do
    run_scrape("battlefield_6")
  end

  desc "Scrape and import Baldur's Gate 3 patch updates from steampowered.com"
  task scrape_baldurs_gate_3: :environment do
    run_scrape("baldurs_gate_3")
  end

  desc "Scrape and import Genshin Impact update posts from hoyolab.com"
  task scrape_genshin_impact: :environment do
    run_scrape("genshin_impact")
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

  desc "Scrape and import League of Legends patch notes from leagueoflegends.com"
  task scrape_league_of_legends: :environment do
    run_scrape("league_of_legends")
  end

  desc "Scrape and import Counter-Strike 2 updates from steampowered.com"
  task scrape_counter_strike_2: :environment do
    run_scrape("counter_strike_2")
  end

  desc "Scrape and import VALORANT patch notes from playvalorant.com"
  task scrape_valorant: :environment do
    run_scrape("valorant")
  end

  desc "Scrape and import Overwatch 2 patch notes from ga.overwatch.blizzard.com"
  task scrape_overwatch_2: :environment do
    run_scrape("overwatch_2")
  end

  desc "Scrape and import Resident Evil Requiem official announcements from steamcommunity.com"
  task scrape_resident_evil_requiem: :environment do
    run_scrape("resident_evil_requiem")
  end

  desc "Scrape and import Horizon Forbidden West Complete Edition updates from steampowered.com"
  task scrape_horizon_forbidden_west: :environment do
    run_scrape("horizon_forbidden_west")
  end

  desc "Scrape and import Cyberpunk 2077 patch notes from steampowered.com"
  task scrape_cyberpunk_2077: :environment do
    run_scrape("cyberpunk_2077")
  end

  desc "Scrape and import Warhammer 40,000: Space Marine 2 patch notes from community.focus-entmt.com"
  task scrape_space_marine_2: :environment do
    run_scrape("space_marine_2")
  end

  desc "Scrape and import Marvel's Spider-Man 2 PC patch notes from steampowered.com"
  task scrape_spider_man_2: :environment do
    run_scrape("spider_man_2")
  end

  desc "Import curated official GTA 5: Online update notes"
  task scrape_gta_5_online: :environment do
    run_scrape("gta_5_online")
  end

  desc "Scrape and import Dota 2 updates from steampowered.com"
  task scrape_dota_2: :environment do
    run_scrape("dota_2")
  end

  desc "Scrape and import Final Fantasy VII Rebirth updates from steampowered.com"
  task scrape_ff7_rebirth: :environment do
    run_scrape("ff7_rebirth")
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

  desc "Scrape and import Call of Duty: Black Ops 7 patch notes from callofduty.com"
  task scrape_call_of_duty_black_ops_7: :environment do
    run_scrape("call_of_duty_black_ops_7")
  end

  desc "Scrape and import Star Wars Battlefront II updates from ea.com"
  task scrape_star_wars_battlefront_ii: :environment do
    run_scrape("star_wars_battlefront_ii")
  end

  desc "Scrape and import patch notes for all configured games"
  task scrape_all: :environment do
    failures = []

    PatchScrapeRunner.scrapeable_sources.each do |source|
      result = run_scrape(source, continue_on_error: true)
      failures << source if result.nil?
    end

    skipped_sources = PatchScrapeRunner.sources - PatchScrapeRunner.scrapeable_sources

    if failures.any?
      puts
      puts "Completed with failures for: #{failures.join(', ')}"
    else
      puts
      puts "Completed successfully for all sources."
    end

    if skipped_sources.any?
      puts "Skipped sources that need alternate ingestion: #{skipped_sources.join(', ')}"
    end
  end
end
