class PatchScrapeRunner
  Result = Struct.new(:source, :label, :imported, :skipped, keyword_init: true)
  Diagnostic = Struct.new(:source, :label, :imported, :skipped, :success, :error_message, :timestamp, keyword_init: true)

  SOURCES = {
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
      missing_game_error: "Helldivers 2 game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Helldivers 2' or slugged 'helldivers-2'."
    },
    "destiny_2" => {
      label: "Destiny 2",
      importer: PatchImporters::Destiny2Importer,
      game_slugs: ["destiny-2"],
      missing_game_error: "Destiny 2 game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Destiny 2' or slugged 'destiny-2'."
    },
    "minecraft" => {
      label: "Minecraft",
      importer: PatchImporters::MinecraftImporter,
      game_slugs: ["minecraft"],
      missing_game_error: "Minecraft game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Minecraft' or slugged 'minecraft'."
    },
    "valorant" => {
      label: "VALORANT",
      importer: PatchImporters::ValorantImporter,
      game_slugs: ["valorant"],
      missing_game_error: "VALORANT game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Valorant' or slugged 'valorant'."
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
    }
  }.freeze

  def self.sources
    SOURCES.keys
  end

  def self.fetch(source)
    SOURCES.fetch(source.to_s)
  end

  def self.run(source)
    new(source).call
  end

  def self.run_all
    sources.map { |source| run(source) }
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
    sources.map { |source| run_with_diagnostics(source) }
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
