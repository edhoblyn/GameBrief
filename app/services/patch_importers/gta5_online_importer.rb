module PatchImporters
  class Gta5OnlineImporter
    Result = Struct.new(:imported, :skipped, keyword_init: true)

    GAME_SLUGS = [
      "gta-5-online",
      "grand-theft-auto-v"
    ].freeze

    GAME_NAMES = [
      "GTA 5: Online",
      "Grand Theft Auto V",
      "GTA V: Online",
      "GTA V Online"
    ].freeze

    PATCHES = [
      {
        title: "GTAV Title Update 1.72 Notes (PS5 / PS4 / Xbox Series X|S / Xbox One / PC [Enhanced/Legacy])",
        source_url: "https://support.rockstargames.com/articles/0ExWSr9Bvq5Putzsn5w54/gtav-title-update-1-72-notes-ps5-ps4-xbox-series-x-or-s-xbox-one-pc-enhanced",
        published_at: Time.zone.parse("2026-02-11"),
        content: <<~TEXT
          New Content
          - The A Safehouse in the Hills update added three Mansion properties through Prix Luxury Real Estate.
          - Mansions include an AI assistant, a master control terminal, trophy cabinets, stat-training areas, a 20-car garage, a private nightclub, and a personal vault.
          - Added five new story missions for 1 to 4 players, plus the Getaway Driver random event.
          - Added five vehicles: Vapid FMJ MK V, Progen Luiva, Pfister X-treme, Ubermacht Sentinel XS4, and Grotti GT750.
          - Added the Rockstar Mission Creator, including example missions players can edit and publish.

          Fixes and Improvements
          - Fixed multiple Home Sweet Home progression blockers and an A Clean Break cutscene issue.
          - Fixed mansion garage problems that could remove HSW upgrades, special liveries, and vehicle mods.
          - Fixed long load times when changing sessions or entering properties and improved GTA Online network stability.
          - Updated GTAV Enhanced to DLSS 2.9.1 so Frame Generation can be used with VSync.

          Post-launch Notes
          - January 14, 2026: fixed mansion fast travel respawns and several Mission Creator settings that carried over between sessions.
          - January 27, 2026: added Wanted Level options to Mission Creator and fixed team testing, placement, and actor behavior issues.
          - February 11, 2026: fixed mansion trophy and production boost issues, plus bugs affecting the Firefighter Odd Job and A Clean Break.
        TEXT
      },
      {
        title: "GTAV Title Update 1.71 Notes (PS5 / PS4 / Xbox Series X|S / Xbox One / PC [Enhanced/Legacy])",
        source_url: "https://support.rockstargames.com/articles/5IxfVX33w3X8fKooGKswfj/gtav-title-update-1-71-notes-ps5-ps4-xbox-series-x-or-s-xbox-one-pc-enhanced",
        published_at: Time.zone.parse("2025-10-22"),
        content: <<~TEXT
          New Content
          - The Money Fronts update introduced the Hands On Car Wash, Higgins Helitours, and Smoke on the Water money laundering businesses.
          - Added QuickiePharm Medical Courier jobs and Safeguard Deliveries as repeatable cash and RP activities.
          - Added seven launch vehicles, including the Overflod Suzume, Dewbauchee Rapid GT X, Karin Woodlander, Ubermacht Sentinel GTS, Annis Hardy, Karin Everon RS, and Western Police Bike.
          - Expanded Imani Tech Missile Lock-On Jammer support to a wider pool of returning vehicles.

          Experience Improvements
          - Players can now skip many mission cutscenes after watching them once.
          - The global signal timer on affected sell missions was increased to 60 seconds.
          - The Boxville biker sell mission was removed and ongoing Boss works can now be canceled from the phone job list.
          - Survival ammo now restocks when players return to Freemode.

          Post-launch Notes
          - August 14, 2025: added Drift Tune upgrades for the Gauntlet Hellfire, Dominator FX, Chavos V6, and Hardy.
          - August 28, 2025: launched the Cayo Perico Survival seasonal mode.
          - September 2, 2025: fixed owned weapon access in Cayo Perico Survival.
          - October 2, 2025: returned Halloween content and added Island Zombie presets to the Survival Creator.
          - October 16, 2025: added the Slasher (Ramius Submarine) variation.
          - October 22, 2025: shipped additional PS5 stability and security fixes.
        TEXT
      }
    ].freeze

    def call
      game = find_game
      raise ActiveRecord::RecordNotFound, "GTA 5: Online game not found" if game.nil?

      imported = 0
      skipped = 0

      PATCHES.each do |data|
        patch = Patch.find_or_initialize_by(source_url: data[:source_url])

        if patch.new_record?
          imported += 1
        else
          skipped += 1
        end

        patch.update!(Patch.import_attributes(data, game: game, existing_patch: patch))
      end

      cleanup_placeholder_patches(game)

      Result.new(imported: imported, skipped: skipped)
    end

    private

    def find_game
      Game.find_by(slug: GAME_SLUGS) ||
        Game.where("LOWER(name) IN (?)", GAME_NAMES.map(&:downcase)).order(:id).first
    end

    def cleanup_placeholder_patches(game)
      game.patches.where(source_url: nil).destroy_all
    end
  end
end
