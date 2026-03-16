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

  desc "Import all games' real events (run each source in turn)"
  task import_all: :environment do
    Rake::Task["events:import_apex_legends"].invoke
    Rake::Task["events:import_arc_raiders"].invoke
    Rake::Task["events:import_battlefield_6"].invoke
    Rake::Task["events:import_call_of_duty_warzone"].invoke
    Rake::Task["events:import_clash_of_clans"].invoke
    Rake::Task["events:import_valorant"].invoke
  end
end
