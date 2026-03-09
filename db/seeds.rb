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

fortnite  = import_game(client, "Fortnite")
warzone   = import_game(client, "Call of Duty: Warzone")
apex      = import_game(client, "Apex Legends")
destiny   = import_game(client, "Destiny 2")
fifa      = import_game(client, "EA Sports FC 24")
roblox    = import_game(client, "Roblox")
clash     = import_game(client, "Clash Royale")

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
    - Boats have been removed from non-coastal areas.

    Bug Fixes
    - Fixed an issue where players could clip through certain building pieces.
    - Fixed the Storm King Mythic not appearing in floor loot rotations.
    - Addressed several audio desync issues in late-game circles.
  TEXT
)

warzone_patch = Patch.create!(
  game: warzone,
  title: "Season 4 Weapon Tuning",
  content: <<~TEXT
    Weapon Balancing
    - Assault Rifles: MTZ-556 damage range increased by 8%. BAS-B fire rate slightly reduced.
    - SMGs: Striker 9 recoil increased to reduce long-range dominance. WSP Swarm minimum damage reduced from 18 to 16.
    - Snipers: KATT-AMR upper chest shot multiplier reduced from 1.5 to 1.35.
    - LMGs: DG-58 LSW maximum damage increased from 28 to 31.

    Movement
    - Slide cancel speed slightly reduced to bring movement in line with intended pace.
    - Mantling speed increased on certain terrain types.

    Gulag
    - Season 4 Gulag: Close Quarters now features rotating loadouts with an updated weapon pool.
    - Gulag overtime mechanic adjusted — the power position now spawns closer to the centre.

    Bug Fixes
    - Fixed an issue where players could duplicate self-revive kits using a specific inventory swap.
    - Resolved crash occurring when spectating a player during Buy Station interaction.
    - Fixed several audio issues with vehicle engine sounds cutting out mid-match.
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
    - Flatline: Damage increased from 19 to 20.
    - Volt SMG: Magazine size reduced from 19 to 16 at base.
    - Longbow DMR: Skullpiercer headshot multiplier reduced from 2.1 to 2.0.
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

destiny_patch = Patch.create!(
  game: destiny,
  title: "Season of Echoes Update",
  content: <<~TEXT
    New Content
    - New 6-player raid: The Vault of Fractured Light. Available on normal and master difficulty from launch.
    - Seasonal weapon set includes 6 new weapons: 2 primary, 2 special, 2 heavy. All craftable after 5 red border drops.
    - New seasonal artifact with 12 mods across 5 columns.

    Sandbox Changes
    - Solar subclass: Radiant buff duration increased from 8s to 10s.
    - Void subclass: Volatile Rounds now trigger on any Void weapon kill when the perk is active.
    - Stasis subclass: Shatter damage against minibosses reduced by 15%.
    - Heavy Grenade Launchers: Spike Grenade damage bonus increased from 15% to 20%.

    Exotic Changes
    - Gjallarhorn: Wolfpack Rounds now scale with Surge mods.
    - Outbreak Perfected: Nanite swarm damage increased by 10%.
    - Thorn: Mark of the Devourer DoT ticks slightly more frequently.

    Bug Fixes
    - Fixed Grandmaster Nightfall modifiers not applying correctly on the first encounter.
    - Resolved seasonal rank resets not granting correct Bright Dust amounts.
    - Fixed geometry clipping in the new patrol zone.
  TEXT
)

fifa_patch = Patch.create!(
  game: fifa,
  title: "Title Update 10 — FUT Balance",
  content: <<~TEXT
    Ultimate Team
    - Pack weight for high-rated players increased for a limited period around Team of the Season.
    - SBC catalogue updated with 3 new squad-building challenges offering rare player rewards.
    - FUT Champions point requirements adjusted — Win 1 now earns more points than previously.

    Gameplay
    - Heading accuracy for players rated below 70 Heading slightly reduced.
    - Through ball interception logic improved — defenders react more consistently to lobbed through balls.
    - Goalkeeper positioning on near-post shots adjusted to reduce unrealistic saves.
    - Sprint speed cap applied to players performing skill moves to prevent unrealistic acceleration bursts.

    Career Mode
    - Fixed an issue where player morale would incorrectly drop after winning a match.
    - Youth Academy players now correctly appear in the correct age range.

    Bug Fixes
    - Fixed stuttering on certain stadium celebrations.
    - Resolved rare crash when entering the FUT transfer market on console.
    - Fixed player name display issue in certain kit combinations.
  TEXT
)

roblox_patch = Patch.create!(
  game: roblox,
  title: "Engine Update — Physics & Performance",
  content: <<~TEXT
    Performance Improvements
    - Rendering pipeline updated to reduce frame drops in high-player-count servers.
    - Memory usage optimised for devices with 2GB RAM — improved stability on mobile.
    - Loading times for large experiences reduced by approximately 15%.

    Physics Updates
    - Anchored part collision detection improved for more consistent behaviour.
    - Humanoid fall damage calculation updated to be smoother across different surface types.
    - Water physics buoyancy adjusted — objects float more realistically.

    Avatar Editor
    - New layered clothing system supports 8 simultaneous clothing layers (up from 5).
    - Bundle previews now display animations in real time before purchase.

    Developer Tools
    - Script Profiler updated with new flame graph view for performance debugging.
    - Studio terrain tools updated with smoother brush edge blending.

    Bug Fixes
    - Fixed intermittent issue where chat messages would not send in certain game modes.
    - Resolved avatar accessories clipping through layered clothing on certain body types.
    - Fixed teleport service failing silently when the destination place was loading.
  TEXT
)

clash_patch = Patch.create!(
  game: clash,
  title: "Balance Update — Card Adjustments",
  content: <<~TEXT
    Card Balance Changes

    Buffs
    - Goblin Giant: Hitpoints increased by 3%.
    - Dark Prince: Shield hitpoints increased by 5%. Charge speed slightly increased.
    - Mortar: First attack speed reduced from 1.5s to 1.2s.
    - Skeleton Dragons: Area damage radius increased slightly.

    Nerfs
    - Evo Firecracker: No longer splits on death when Evolved. Base Firecracker split on death unchanged.
    - Little Prince: Guard spawn interval increased from 20s to 23s.
    - Golden Knight: Dash damage reduced by 5%.
    - Mighty Miner: Drill hitpoints reduced by 6%.

    New Evolution
    - Evo Cannon Cart: Now gains a temporary speed boost when its cart is destroyed. Available from Season 52.

    Season 52 Changes
    - New season pass with exclusive tower skin: Neon Arcade Tower.
    - Global Tournament format updated — best-of-3 now applies from top 1000 onward.

    Bug Fixes
    - Fixed Evo Giant Skeleton bomb sometimes not triggering on certain terrain edges.
    - Resolved rare visual glitch where cards appeared greyed out despite being ready.
    - Fixed clan war boat battle win not counting in certain edge cases.
  TEXT
)

puts "Creating patch summaries..."

PatchSummary.create!(
  patch: fortnite_patch,
  summary: "Guns feel a bit more accurate this patch — ARs got a damage boost and bloom was reduced so your shots land more consistently. Two new named locations dropped in the northwest, so expect hot drops there early on. Shotguns got a slight nerf at the top end, so don't rely on one-pumping as much."
)

PatchSummary.create!(
  patch: warzone_patch,
  summary: "The MTZ-556 AR got a range buff making it stronger at distance, while the Striker 9 SMG was pulled back to stop it dominating at longer ranges. Slide cancelling is slightly slower so movement feels less frantic. The Gulag got refreshed with a rotating weapon pool which keeps close quarters matches feeling fresh."
)

PatchSummary.create!(
  patch: apex_patch,
  summary: "Bloodhound and Wraith got buffed — Wraith's void ability is up more often and Bloodhound scans a bit further. Gibraltar took hits to both his dome cooldown and gun shield so he's a little weaker this patch. The new Squad Royale LTM is worth trying if you want a chaotic team mode with cosmetic rewards."
)

PatchSummary.create!(
  patch: destiny_patch,
  summary: "Big patch this season — there's a brand new raid called the Vault of Fractured Light plus a fresh set of craftable seasonal weapons. Solar and Void builds got small buffs so if you've been running those subclasses you'll feel stronger. Stasis shatter got toned down in higher-end content so pure Stasis builds may want to adjust."
)

PatchSummary.create!(
  patch: fifa_patch,
  summary: "Pack weights are temporarily boosted around Team of the Season so it's a good time to open packs if you've been saving. Heading has been toned down for weaker players and through ball defending is more consistent, which should reduce some frustrating goals. FUT Champions now rewards points more fairly for lower win counts."
)

PatchSummary.create!(
  patch: roblox_patch,
  summary: "A performance-focused update — loading times are roughly 15% faster and mobile devices should crash less often in busy servers. Layered clothing now supports 8 layers so you can style your avatar even more. Developers get a new flame graph profiler tool to help track down lag in their games."
)

PatchSummary.create!(
  patch: clash_patch,
  summary: "Goblin Giant and Dark Prince got some love this patch with hitpoint and shield buffs, making them more viable in ladder. Evo Firecracker lost her death split when evolved which was a significant nerf to one of the most popular evolutions. A new Evo Cannon Cart is coming in Season 52 with a speed burst after its cart is destroyed."
)

puts "Creating events..."

Event.create!(
  game: fortnite,
  title: "End of Season Live Event",
  description: "The Chapter 6 finale live in-game event. All players online at the time will experience the event together.",
  start_date: DateTime.now + 14.days
)

Event.create!(
  game: warzone,
  title: "Double XP Weekend",
  description: "Earn double weapon and operator XP across all Warzone modes for the full weekend.",
  start_date: DateTime.now + 5.days
)

Event.create!(
  game: apex,
  title: "Anniversary Collection Event",
  description: "Limited-time cosmetics, themed LTMs and exclusive event challenges with a free legendary reward track.",
  start_date: DateTime.now + 8.days
)

Event.create!(
  game: destiny,
  title: "Iron Banner Returns",
  description: "The limited-time PvP event is back. Earn Iron Banner armour and weapons through matches and bounties.",
  start_date: DateTime.now + 4.days
)

Event.create!(
  game: fifa,
  title: "Team of the Season",
  description: "TOTS is live — the best performing players from Europe's top leagues get special high-rated cards in packs.",
  start_date: DateTime.now + 2.days
)

Event.create!(
  game: roblox,
  title: "Egg Hunt 2025",
  description: "The annual Roblox Egg Hunt event is back. Find eggs hidden across participating experiences to earn exclusive avatar items.",
  start_date: DateTime.now + 10.days
)

Event.create!(
  game: clash,
  title: "Season 52 Start",
  description: "Season 52 kicks off with the new Neon Arcade Tower skin, updated Global Tournament format and the Evo Cannon Cart.",
  start_date: DateTime.now + 3.days
)

puts "Seeds finished!"
