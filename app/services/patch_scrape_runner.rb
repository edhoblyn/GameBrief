class PatchScrapeRunner
  Result = Struct.new(:source, :label, :imported, :skipped, keyword_init: true)

  SOURCES = {
    "marvel_rivals" => {
      label: "Marvel Rivals",
      importer: PatchImporters::MarvelRivalsImporter,
      missing_game_error: "Marvel Rivals game not found in the database.",
      missing_game_hint: "Run: Game.create!(name: 'Marvel Rivals', slug: 'marvel-rivals', genre: ['shooter'])"
    },
    "warzone" => {
      label: "Call of Duty: Warzone",
      importer: PatchImporters::WarzoneImporter,
      missing_game_error: "Warzone game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Call of Duty: Warzone' or slugged 'call-of-duty-warzone'."
    },
    "fortnite" => {
      label: "Fortnite",
      importer: PatchImporters::FortniteImporter,
      missing_game_error: "Fortnite game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Fortnite' or slugged 'fortnite'."
    },
    "apex_legends" => {
      label: "Apex Legends",
      importer: PatchImporters::ApexLegendsImporter,
      missing_game_error: "Apex Legends game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Apex Legends' or slugged 'apex-legends'."
    },
    "ea_sports_fc_26" => {
      label: "EA Sports FC 26",
      importer: PatchImporters::EaSportsFc26Importer,
      missing_game_error: "EA Sports FC 26 game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'EA Sports FC 26' or slugged 'ea-sports-fc-26'."
    },
    "helldivers_2" => {
      label: "Helldivers 2",
      importer: PatchImporters::Helldivers2Importer,
      missing_game_error: "Helldivers 2 game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Helldivers 2' or slugged 'helldivers-2'."
    },
    "destiny_2" => {
      label: "Destiny 2",
      importer: PatchImporters::Destiny2Importer,
      missing_game_error: "Destiny 2 game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Destiny 2' or slugged 'destiny-2'."
    },
    "minecraft" => {
      label: "Minecraft",
      importer: PatchImporters::MinecraftImporter,
      missing_game_error: "Minecraft game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Minecraft' or slugged 'minecraft'."
    },
    "valorant" => {
      label: "VALORANT",
      importer: PatchImporters::ValorantImporter,
      missing_game_error: "VALORANT game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Valorant' or slugged 'valorant'."
    },
    "roblox" => {
      label: "Roblox",
      importer: PatchImporters::RobloxImporter,
      missing_game_error: "Roblox game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Roblox' or slugged 'roblox'."
    },
    "clash_royale" => {
      label: "Clash Royale",
      importer: PatchImporters::ClashRoyaleImporter,
      missing_game_error: "Clash Royale game not found in the database.",
      missing_game_hint: "Expected an existing Game named 'Clash Royale' or slugged 'clash-royale'."
    },
    "clash_of_clans" => {
      label: "Clash of Clans",
      importer: PatchImporters::ClashOfClansImporter,
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
