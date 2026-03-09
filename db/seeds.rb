# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Cleaning database..."

Reminder.destroy_all
Event.destroy_all
PatchSummary.destroy_all
Patch.destroy_all
Favourite.destroy_all
Game.destroy_all
User.destroy_all

puts "Creating users..."

user = User.create!(
  email: "demo@test.com",
  password: "123456"
)

puts "Importing games from IGDB..."

client = IgdbClient.new

def import_game(client, query)
  results = client.search_games(query)
  match = results.find { |g| g["name"]&.downcase == query.downcase && g["cover"] }
  match ||= results.find { |g| g["cover"] }
  match ||= results.first
  return nil unless match

  cover_url = match["cover"] ? "https:#{match["cover"]["url"].gsub("t_thumb", "t_cover_big")}" : nil

  Game.create!(
    name: match["name"],
    slug: match["slug"],
    cover_image: cover_url
  )
end

fortnite = import_game(client, "Fortnite")
destiny  = import_game(client, "Destiny 2")
apex     = import_game(client, "Apex Legends")

puts "Creating patches..."

fortnite_patch = Patch.create!(
  game: fortnite,
  title: "Chapter 6 Balance Update",
  content: <<~TEXT
    Weapons
    - Assault Rifles: Reduced bloom by 12% across all rarities. Common AR damage increased from 30 to 32.
    - Shotguns: Pump shotgun fire rate increased slightly. Charge shotgun max damage reduced from 220 to 200.
    - SMGs: Magazine size increased from 30 to 35. Reload time reduced by 0.3s on Epic and Legendary variants.
    - Sniper Rifles: Heavy Sniper now deals 10% less damage to structures.

    Map Changes
    - Two new named locations added to the northwest: Frosted Falls and Ember Ridge.
    - The central river area has been expanded with new bridge structures and cover points.
    - Several unnamed POIs updated with loot pool adjustments.

    Vehicles
    - Dirt bikes now spawn more frequently in the northern biome.
    - boats have been removed from non-coastal areas.

    Bug Fixes
    - Fixed an issue where players could clip through certain building pieces.
    - Fixed the Storm King Mythic not appearing in floor loot rotations.
    - Addressed several audio desync issues in late-game circles.
  TEXT
)

destiny_patch = Patch.create!(
  game: destiny,
  title: "Season of Echoes",
  content: <<~TEXT
    New Content
    - New 6-player raid: The Vault of Fractured Light. Available on normal and master difficulty from launch.
    - Seasonal weapon set includes 6 new weapons: 2 primary, 2 special, 2 heavy. All craftable after 5 red border drops.
    - New seasonal artifact with 12 mods across 5 columns. Overload and Unstoppable champions are prioritised this season.

    Sandbox Changes
    - Solar subclass: Radiant buff duration increased from 8s to 10s.
    - Void subclass: Volatile Rounds now trigger on any Void weapon kill when the perk is active, not just Void abilities.
    - Stasis subclass: Shatter damage against minibosses and above reduced by 15%.
    - Heavy Grenade Launchers: Spike Grenade intrinsic damage bonus increased from 15% to 20%.
    - Linear Fusion Rifles: Charge time reduced by 20ms across the archetype.

    Exotic Changes
    - Gjallarhorn: Wolfpack Rounds now scale with Surge mods.
    - Outbreak Perfected: Nanite swarm damage increased by 10%.
    - Thorn: Mark of the Devourer DoT ticks slightly more frequently.

    Bug Fixes
    - Fixed Grandmaster Nightfall modifiers not applying correctly on the first encounter.
    - Resolved an issue where seasonal rank resets were not granting the correct Bright Dust amounts.
    - Fixed several cases of geometry clipping in the new patrol zone.
  TEXT
)

apex_patch = Patch.create!(
  game: apex,
  title: "Mid-Season Update",
  content: <<~TEXT
    Legend Balance

    Bloodhound
    - Passive: Tracker clues now visible from 20m (up from 15m).
    - Ultimate: Beast of the Hunt duration reduced from 35s to 30s.

    Gibraltar
    - Dome Shield cooldown increased from 20s to 25s.
    - Gun Shield health reduced from 75 to 65.

    Wraith
    - Into the Void cooldown reduced from 25s to 22s.
    - Dimensional Rift activation time reduced by 0.5s.

    Newcastle
    - Mobile Shield now has 20% more health across all levels.
    - Revive passive now grants 15 shield on revive completion (down from 25).

    Weapon Changes
    - Flatline: Damage increased from 19 to 20. Now uses Light Ammo in Care Package variant.
    - Volt SMG: Magazine size reduced from 19 to 16 at base.
    - Longbow DMR: Skullpiercer hop-up headshot multiplier reduced from 2.1 to 2.0.
    - 30-30 Repeater: Recoil pattern adjusted to be more consistent.

    New Limited-Time Mode: Squad Royale
    - Teams of 9 (3 squads of 3) land together and compete as a large unit.
    - Final ring triggers a free-for-all between the last two mega-squads.
    - Available for 2 weeks with exclusive cosmetic rewards for wins.

    Bug Fixes
    - Fixed Seer's Exhibit ultimate not detecting crouching enemies correctly.
    - Resolved hitbox misalignment on Revenant Reborn during certain animations.
    - Fixed audio cues for Trident vehicle not playing on low settings.
  TEXT
)

puts "Creating patch summaries..."

PatchSummary.create!(
  patch: fortnite_patch,
  summary: "Guns feel a bit more accurate this patch — ARs got a damage boost and bloom was reduced, so your shots will land more consistently. Two new named locations dropped in the northwest, so expect hot drops there early on. Shotguns got a slight nerf at the top end, so don't rely on one-pumping as much."
)

PatchSummary.create!(
  patch: destiny_patch,
  summary: "Big patch this season — there's a brand new raid called the Vault of Fractured Light to run with your fireteam, plus a fresh set of craftable seasonal weapons. Solar and Void builds got small buffs, so if you've been running those subclasses you'll feel a bit stronger. Stasis shatter got toned down in higher-end content, so pure Stasis builds may want to adjust."
)

PatchSummary.create!(
  patch: apex_patch,
  summary: "Bloodhound and Wraith got buffed — Wraith's void ability is up more often, and Bloodhound scans a bit further. Gibraltar took hits to both his dome cooldown and gun shield, so he's a little weaker this patch. The new Squad Royale LTM is worth checking out if you want a chaotic team mode with cosmetic rewards on the line."
)

puts "Creating events..."

Event.create!(
  game: fortnite,
  title: "Fortnite Live Event",
  description: "End of season live event",
  start_date: DateTime.now + 7.days
)

Event.create!(
  game: destiny,
  title: "Iron Banner",
  description: "Limited-time PvP event",
  start_date: DateTime.now + 5.days
)

Event.create!(
  game: apex,
  title: "Collection Event",
  description: "Limited cosmetics and challenges",
  start_date: DateTime.now + 10.days
)

puts "Seeds finished!"
