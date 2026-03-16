class PatchScrapeRunner
  Result = Struct.new(:source, :label, :imported, :skipped, keyword_init: true)
  Diagnostic = Struct.new(:source, :label, :imported, :skipped, :success, :error_message, :timestamp, keyword_init: true)

  SOURCES = {
    "battlefield_6" => {
      label: "Battlefield 6",
      importer: PatchImporters::Battlefield6Importer,
      game_slugs: ["battlefield-6"],
      missing_game_error: "Battlefield 6 game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Battlefield 6' or slugged 'battlefield-6'."
    },
    "arc_raiders" => {
      label: "ARC Raiders",
      importer: PatchImporters::ArcRaidersImporter,
      game_slugs: ["arc-raiders"],
      missing_game_error: "ARC Raiders game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'ARC Raiders' or slugged 'arc-raiders'."
    },
    "marvel_rivals" => {
      label: "Marvel Rivals",
      importer: PatchImporters::MarvelRivalsImporter,
      game_slugs: ["marvel-rivals"],
      missing_game_error: "Marvel Rivals game not found in the database.",
      missing_game_hint: "Run: Game.create!(name: 'Marvel Rivals', slug: 'marvel-rivals', genre: ['shooter'])"
    },
    "warzone" => {
      label: "Call of Duty: Warzone",
      importer: PatchImporters::WarzoneImporter,
      game_slugs: ["call-of-duty-warzone"],
      missing_game_error: "Warzone game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Call of Duty: Warzone' or slugged 'call-of-duty-warzone'."
    },
    "fortnite" => {
      label: "Fortnite",
      importer: PatchImporters::FortniteImporter,
      game_slugs: ["fortnite"],
      ingestion_method: "api",
      manual_trigger_enabled: false,
      disabled_message: "Fortnite currently requires an API or alternate endpoint because the official news page is behind bot protection.",
      missing_game_error: "Fortnite game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Fortnite' or slugged 'fortnite'."
    },
    "apex_legends" => {
      label: "Apex Legends",
      importer: PatchImporters::ApexLegendsImporter,
      game_slugs: ["apex-legends"],
      missing_game_error: "Apex Legends game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Apex Legends' or slugged 'apex-legends'."
    },
    "ea_sports_fc_26" => {
      label: "EA Sports FC 26",
      importer: PatchImporters::EaSportsFc26Importer,
      game_slugs: ["ea-sports-fc-26"],
      missing_game_error: "EA Sports FC 26 game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'EA Sports FC 26' or slugged 'ea-sports-fc-26'."
    },
    "helldivers_2" => {
      label: "Helldivers 2",
      importer: PatchImporters::Helldivers2Importer,
      game_slugs: ["helldivers-2"],
      ingestion_method: "api",
      manual_trigger_enabled: false,
      disabled_message: "Helldivers 2 currently requires an API or alternate endpoint because the official patch-notes section is behind bot protection.",
      missing_game_error: "Helldivers 2 game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Helldivers 2' or slugged 'helldivers-2'."
    },
    "destiny_2" => {
      label: "Destiny 2",
      importer: PatchImporters::Destiny2Importer,
      game_slugs: ["destiny-2"],
      ingestion_method: "api",
      manual_trigger_enabled: false,
      disabled_message: "Destiny 2 currently requires an API or alternate endpoint because the official Bungie news feed is JS-driven and not reliably scrapeable.",
      missing_game_error: "Destiny 2 game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Destiny 2' or slugged 'destiny-2'."
    },
    "minecraft" => {
      label: "Minecraft",
      importer: PatchImporters::MinecraftImporter,
      game_slugs: ["minecraft"],
      ingestion_method: "api",
      manual_trigger_enabled: false,
      disabled_message: "Minecraft currently requires an API or alternate endpoint because the official changelog section is behind bot protection.",
      missing_game_error: "Minecraft game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Minecraft' or slugged 'minecraft'."
    },
    "league_of_legends" => {
      label: "League of Legends",
      importer: PatchImporters::LeagueOfLegendsImporter,
      game_slugs: ["league-of-legends"],
      missing_game_error: "League of Legends game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'League of Legends' or slugged 'league-of-legends'."
    },
    "counter_strike_2" => {
      label: "Counter-Strike 2",
      importer: PatchImporters::CounterStrike2Importer,
      game_slugs: ["counter-strike-2"],
      missing_game_error: "Counter-Strike 2 game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Counter-Strike 2' or slugged 'counter-strike-2'."
    },
    "pubg_battlegrounds" => {
      label: "PUBG: Battlegrounds",
      importer: PatchImporters::PubgBattlegroundsImporter,
      game_slugs: ["pubg-battlegrounds", "playerunknowns-battlegrounds"],
      missing_game_error: "PUBG: Battlegrounds game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'PUBG: Battlegrounds' or slugged 'pubg-battlegrounds'."
    },
    "valorant" => {
      label: "VALORANT",
      importer: PatchImporters::ValorantImporter,
      game_slugs: ["valorant"],
      missing_game_error: "VALORANT game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Valorant' or slugged 'valorant'."
    },
    "overwatch_2" => {
      label: "Overwatch 2",
      importer: PatchImporters::Overwatch2Importer,
      game_slugs: ["overwatch-2", "overwatch-2-invasion-bundle--1"],
      missing_game_error: "Overwatch 2 game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Overwatch 2' or slugged 'overwatch-2'."
    },
    "resident_evil_requiem" => {
      label: "Resident Evil Requiem",
      importer: PatchImporters::ResidentEvilRequiemImporter,
      game_slugs: ["resident-evil-requiem", "biohazard-requiem"],
      missing_game_error: "Resident Evil Requiem game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Resident Evil Requiem' or slugged 'resident-evil-requiem'."
    },
    "horizon_forbidden_west" => {
      label: "Horizon Forbidden West",
      importer: PatchImporters::HorizonForbiddenWestImporter,
      game_slugs: ["horizon-forbidden-west"],
      missing_game_error: "Horizon Forbidden West game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Horizon Forbidden West' or slugged 'horizon-forbidden-west'."
    },
    "cyberpunk_2077" => {
      label: "Cyberpunk 2077",
      importer: PatchImporters::Cyberpunk2077Importer,
      game_slugs: ["cyberpunk-2077"],
      missing_game_error: "Cyberpunk 2077 game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Cyberpunk 2077' or slugged 'cyberpunk-2077'."
    },
    "spider_man_2" => {
      label: "Marvel's Spider-Man 2",
      importer: PatchImporters::SpiderMan2Importer,
      game_slugs: ["marvels-spider-man-2"],
      missing_game_error: "Marvel's Spider-Man 2 game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Marvel's Spider-Man 2' or slugged 'marvels-spider-man-2'."
    },
    "roblox" => {
      label: "Roblox",
      importer: PatchImporters::RobloxImporter,
      game_slugs: ["roblox"],
      missing_game_error: "Roblox game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Roblox' or slugged 'roblox'."
    },
    "clash_royale" => {
      label: "Clash Royale",
      importer: PatchImporters::ClashRoyaleImporter,
      game_slugs: ["clash-royale"],
      missing_game_error: "Clash Royale game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Clash Royale' or slugged 'clash-royale'."
    },
    "clash_of_clans" => {
      label: "Clash of Clans",
      importer: PatchImporters::ClashOfClansImporter,
      game_slugs: ["clash-of-clans"],
      missing_game_error: "Clash of Clans game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Clash of Clans' or slugged 'clash-of-clans'."
    },
    "pokemon_pokopia" => {
      label: "Pokémon Pokopia",
      importer: PatchImporters::PokemonPokopiaImporter,
      game_slugs: ["pokemon-pokopia"],
      missing_game_error: "Pokémon Pokopia game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Pokémon Pokopia' or slugged 'pokemon-pokopia'."
    },
    "star_wars_battlefront_ii" => {
      label: "Star Wars Battlefront II",
      importer: PatchImporters::StarWarsBattlefront2Importer,
      game_slugs: ["star-wars-battlefront-ii"],
      missing_game_error: "Star Wars Battlefront II game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Star Wars Battlefront II' or slugged 'star-wars-battlefront-ii'."
    }
  }.freeze

  def self.sources
    SOURCES.keys
  end

  def self.runnable_sources
    scrapeable_sources.filter_map do |source|
      source if fetch(source).fetch(:manual_trigger_enabled, true)
    end
  end

  def self.scrapeable_sources
    SOURCES.filter_map do |source, config|
      source if config.fetch(:ingestion_method, "scrape") == "scrape"
    end
  end

  def self.scrapeable?(source)
    fetch(source).fetch(:ingestion_method, "scrape") == "scrape"
  end

  def self.fetch(source)
    SOURCES.fetch(source.to_s)
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

  def self.manual_trigger_enabled?(source)
    fetch(source).fetch(:manual_trigger_enabled, true)
  end

  def self.config_for_game(game)
    source = source_for_game(game)
    return nil if source.nil?

    fetch(source).merge(source: source)
  end

  def self.source_for_game(game)
    slug = game.slug.to_s

    SOURCES.each do |source, config|
      return source if config.fetch(:game_slugs, []).include?(slug)
    end

    nil
  end

  def initialize(source)
    @source = source.to_s
    @config = self.class.fetch(@source)
  end

  def call
    importer_result = @config[:importer].new.call

    Result.new(
      source: @source,
      label: @config[:label],
      imported: importer_result.imported,
      skipped: importer_result.skipped
    )
  end
end
