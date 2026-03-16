namespace :events do
  def run_event_import(importer_class, label:)
    puts "Importing #{label} events..."
    result = importer_class.new.call(replace: true)
    puts "Done — #{result.imported} imported, #{result.skipped} already existed."
    result
  rescue ActiveRecord::RecordNotFound => e
    puts "ERROR: #{e.message}"
    puts "Hint: Run db:seed first to create the game record."
    exit 1
  rescue StandardError => e
    puts "ERROR: #{e.class}: #{e.message}"
    raise
  end

  desc "Import real Apex Legends events from Liquipedia (ALGS esports) and ea.com (in-game)"
  task import_apex_legends: :environment do
    run_event_import(EventImporters::ApexLegendsEventImporter, label: "Apex Legends")
  end

  desc "Import real Valorant events from vlr.gg (VCT esports) and playvalorant.com (in-game)"
  task import_valorant: :environment do
    run_event_import(EventImporters::ValorantEventImporter, label: "Valorant")
  end

  desc "Import real ARC Raiders events from arcraiders.com (updates, Trials, community)"
  task import_arc_raiders: :environment do
    run_event_import(EventImporters::ArcRaidersEventImporter, label: "ARC Raiders")
  end

  desc "Import real Battlefield 6 events from ea.com/games/battlefield/battlefield-6/news"
  task import_battlefield_6: :environment do
    run_event_import(EventImporters::Battlefield6EventImporter, label: "Battlefield 6")
  end

  desc "Import real Call of Duty: Warzone events from callofduty.com/blog/warzone"
  task import_call_of_duty_warzone: :environment do
    run_event_import(EventImporters::CallOfDutyWarzoneEventImporter, label: "Call of Duty: Warzone")
  end

  desc "Import real Clash of Clans events from supercell.com/en/games/clashofclans/blog"
  task import_clash_of_clans: :environment do
    run_event_import(EventImporters::ClashOfClansEventImporter, label: "Clash of Clans")
  end

  desc "Import real Clash Royale events from supercell.com/en/games/clashroyale/blog"
  task import_clash_royale: :environment do
    run_event_import(EventImporters::ClashRoyaleEventImporter, label: "Clash Royale")
  end

  desc "Import real Counter-Strike 2 events from Steam announcements API"
  task import_counter_strike_2: :environment do
    run_event_import(EventImporters::CounterStrike2EventImporter, label: "Counter-Strike 2")
  end

  desc "Import real Destiny 2 events from Steam announcements API"
  task import_destiny_2: :environment do
    run_event_import(EventImporters::Destiny2EventImporter, label: "Destiny 2")
  end

  desc "Import real Dota 2 events from Steam announcements API"
  task import_dota_2: :environment do
    run_event_import(EventImporters::Dota2EventImporter, label: "Dota 2")
  end

  desc "Import real EA Sports FC 26 events from ea.com/games/ea-sports-fc/fc-26/news"
  task import_ea_sports_fc_26: :environment do
    run_event_import(EventImporters::EaSportsFc26EventImporter, label: "EA Sports FC 26")
  end

  desc "Import real Genshin Impact events from HoYoLAB news API"
  task import_genshin_impact: :environment do
    run_event_import(EventImporters::GenshinImpactEventImporter, label: "Genshin Impact")
  end

  desc "Import real Helldivers 2 events from Steam announcements API"
  task import_helldivers_2: :environment do
    run_event_import(EventImporters::Helldivers2EventImporter, label: "Helldivers 2")
  end

  desc "Import real GTA 5: Online events from Steam announcements API"
  task import_gta_online: :environment do
    run_event_import(EventImporters::GtaOnlineEventImporter, label: "GTA 5: Online")
  end

  desc "Import real League of Legends events from leagueoflegends.com/en-us/news/"
  task import_league_of_legends: :environment do
    run_event_import(EventImporters::LeagueOfLegendsEventImporter, label: "League of Legends")
  end

  desc "Import all games' real events (run each source in turn)"
  task import_all: :environment do
    Rake::Task["events:import_apex_legends"].invoke
    Rake::Task["events:import_arc_raiders"].invoke
    Rake::Task["events:import_battlefield_6"].invoke
    Rake::Task["events:import_call_of_duty_warzone"].invoke
    Rake::Task["events:import_clash_of_clans"].invoke
    Rake::Task["events:import_clash_royale"].invoke
    Rake::Task["events:import_counter_strike_2"].invoke
    Rake::Task["events:import_destiny_2"].invoke
    Rake::Task["events:import_dota_2"].invoke
    Rake::Task["events:import_ea_sports_fc_26"].invoke
    Rake::Task["events:import_genshin_impact"].invoke
    Rake::Task["events:import_gta_online"].invoke
    Rake::Task["events:import_helldivers_2"].invoke
    Rake::Task["events:import_league_of_legends"].invoke
    Rake::Task["events:import_valorant"].invoke
  end
end
