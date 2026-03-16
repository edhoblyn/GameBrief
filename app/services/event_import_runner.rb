class EventImportRunner
  Result     = Struct.new(:source, :label, :imported, :skipped, keyword_init: true)
  Diagnostic = Struct.new(:source, :label, :imported, :skipped, :success, :error_message, :timestamp, keyword_init: true)

  SOURCES = {
    "apex_legends" => {
      label: "Apex Legends",
      importer: EventImporters::ApexLegendsEventImporter,
      game_slugs: ["apex-legends"]
    },
    "arc_raiders" => {
      label: "ARC Raiders",
      importer: EventImporters::ArcRaidersEventImporter,
      game_slugs: ["arc-raiders"]
    },
    "battlefield_6" => {
      label: "Battlefield 6",
      importer: EventImporters::Battlefield6EventImporter,
      game_slugs: ["battlefield-6"],
      manual_trigger_enabled: false,
      disabled_message: "Battlefield 6 events are seeded manually — EA only announces content at launch, not in advance."
    },
    "call_of_duty_warzone" => {
      label: "Call of Duty: Warzone",
      importer: EventImporters::CallOfDutyWarzoneEventImporter,
      game_slugs: ["call-of-duty-warzone", "warzone"],
      manual_trigger_enabled: false,
      disabled_message: "Warzone events are seeded manually — EA only announces content at launch, not in advance."
    },
    "clash_of_clans" => {
      label: "Clash of Clans",
      importer: EventImporters::ClashOfClansEventImporter,
      game_slugs: ["clash-of-clans"],
      manual_trigger_enabled: false,
      disabled_message: "Clash of Clans events are seeded manually — Supercell does not publish a forward-looking events calendar."
    },
    "clash_royale" => {
      label: "Clash Royale",
      importer: EventImporters::ClashRoyaleEventImporter,
      game_slugs: ["clash-royale"],
      manual_trigger_enabled: false,
      disabled_message: "Clash Royale events are seeded manually — Supercell does not publish a forward-looking events calendar."
    },
    "counter_strike_2" => {
      label: "Counter-Strike 2",
      importer: EventImporters::CounterStrike2EventImporter,
      game_slugs: ["counter-strike-2", "cs2"]
    },
    "destiny_2" => {
      label: "Destiny 2",
      importer: EventImporters::Destiny2EventImporter,
      game_slugs: ["destiny-2"],
      manual_trigger_enabled: false,
      disabled_message: "Destiny 2 events are seeded manually — the Steam feed only returns weekly 'This Week In Destiny' posts with no event content."
    },
    "dota_2" => {
      label: "Dota 2",
      importer: EventImporters::Dota2EventImporter,
      game_slugs: ["dota-2"]
    },
    "ea_sports_fc_26" => {
      label: "EA Sports FC 26",
      importer: EventImporters::EaSportsFc26EventImporter,
      game_slugs: ["ea-sports-fc-26", "fc-26"]
    },
    "genshin_impact" => {
      label: "Genshin Impact",
      importer: EventImporters::GenshinImpactEventImporter,
      game_slugs: ["genshin-impact"]
    },
    "gta_online" => {
      label: "GTA 5: Online",
      importer: EventImporters::GtaOnlineEventImporter,
      game_slugs: ["gta-5-online", "grand-theft-auto-online"]
    },
    "helldivers_2" => {
      label: "Helldivers 2",
      importer: EventImporters::Helldivers2EventImporter,
      game_slugs: ["helldivers-2"]
    },
    "league_of_legends" => {
      label: "League of Legends",
      importer: EventImporters::LeagueOfLegendsEventImporter,
      game_slugs: ["league-of-legends"]
    },
    "overwatch_2" => {
      label: "Overwatch 2",
      importer: EventImporters::Overwatch2EventImporter,
      game_slugs: ["overwatch-2", "overwatch"]
    },
    "pubg" => {
      label: "PUBG: Battlegrounds",
      importer: EventImporters::PubgEventImporter,
      game_slugs: ["pubg-battlegrounds", "pubg"]
    },
    "space_marine_2" => {
      label: "Warhammer 40,000: Space Marine 2",
      importer: EventImporters::SpaceMarine2EventImporter,
      game_slugs: ["warhammer-40000-space-marine-ii", "space-marine-2"]
    },
    "valorant" => {
      label: "Valorant",
      importer: EventImporters::ValorantEventImporter,
      game_slugs: ["valorant"]
    }
  }.freeze

  def self.sources
    SOURCES.keys
  end

  def self.runnable_sources
    SOURCES.filter_map do |source, config|
      source if config.fetch(:manual_trigger_enabled, true)
    end
  end

  def self.fetch(source)
    SOURCES.fetch(source.to_s)
  end

  def self.manual_trigger_enabled?(source)
    fetch(source).fetch(:manual_trigger_enabled, true)
  end

  def self.run(source)
    new(source).call
  end

  def self.run_all
    runnable_sources.map { |source| run(source) }
  end

  def self.diagnostic_for_result(result)
    Diagnostic.new(
      source: result.source,
      label: result.label,
      imported: result.imported,
      skipped: result.skipped,
      success: true,
      error_message: nil,
      timestamp: Time.current
    )
  end

  def self.diagnostic_for_error(source, error)
    label = fetch(source)[:label]
    Diagnostic.new(
      source: source.to_s,
      label: label,
      imported: 0,
      skipped: 0,
      success: false,
      error_message: error.message,
      timestamp: Time.current
    )
  rescue KeyError
    Diagnostic.new(
      source: source.to_s,
      label: source.to_s.humanize,
      imported: 0,
      skipped: 0,
      success: false,
      error_message: error.message,
      timestamp: Time.current
    )
  end

  def self.run_with_diagnostics(source)
    diagnostic_for_result(run(source))
  rescue StandardError => e
    diagnostic_for_error(source, e)
  end

  def self.run_all_with_diagnostics
    runnable_sources.map { |source| run_with_diagnostics(source) }
  end

  def initialize(source)
    @source = source.to_s
    @config = self.class.fetch(@source)
  end

  def call
    importer_result = @config[:importer].new.call(replace: true)

    Result.new(
      source: @source,
      label: @config[:label],
      imported: importer_result.imported,
      skipped: importer_result.skipped
    )
  end
end
