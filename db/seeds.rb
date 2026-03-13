puts "Seeding database without deleting real scraped data..."

def upsert_user(email:, password:, **attributes)
  user = User.find_or_initialize_by(email: email)
  user.password = password if user.new_record?
  user.update!(attributes)
  user
end

def seed_placeholder_patch(game:, title:, content:, summaries:)
  return nil unless game

  if game.patches.where.not(source_url: nil).exists?
    game.patches.where(source_url: nil).find_each(&:destroy!)
    puts "Skipping placeholder patch for #{game.name} because scraped patches already exist."
    return nil
  end

  patch = game.patches.where(source_url: nil).order(:id).first_or_initialize
  patch.update!(title: title, content: content)
  patch.patch_summaries.destroy_all

  summaries.each do |summary_type, summary_text|
    patch.patch_summaries.create!(summary: summary_text, summary_type: summary_type)
  end

  patch
end

def seed_event(game:, title:, description:, start_date:)
  return nil unless game

  event = Event.find_or_initialize_by(game: game, title: title)
  event.update!(description: description, start_date: start_date)
  event
end

def seed_event_series(game:, events:)
  events.each do |event_attributes|
    seed_event(game: game, **event_attributes)
  end
end

puts "Creating users..."

user = upsert_user(
  email: "demo@test.com",
  password: "123456"
)

puts "Creating featured gamers..."

upsert_user(email: "edhomey@gamebrief.gg",      password: "password123", username: "Ed Homey",      avatar_url: "https://randomuser.me/api/portraits/men/46.jpg",    follower_count: 84200)
upsert_user(email: "biancastar@gamebrief.gg",   password: "password123", username: "Bianca Star",   avatar_url: "https://randomuser.me/api/portraits/women/73.jpg",  follower_count: 61500)
upsert_user(email: "hortgamer@gamebrief.gg",    password: "password123", username: "Hort Gamer",    avatar_url: "https://randomuser.me/api/portraits/women/44.jpg",  follower_count: 43900)
upsert_user(email: "baptistex@gamebrief.gg",    password: "password123", username: "BaptisteX",     avatar_url: "https://randomuser.me/api/portraits/men/78.jpg",    follower_count: 29300)
upsert_user(email: "zerolagguru@gamebrief.gg",  password: "password123", username: "ZeroLagGuru",   avatar_url: "https://randomuser.me/api/portraits/men/11.jpg",    follower_count: 25100)
upsert_user(email: "pixelqueenv@gamebrief.gg",  password: "password123", username: "PixelQueenV",   avatar_url: "https://randomuser.me/api/portraits/women/15.jpg",  follower_count: 22700)
upsert_user(email: "snipersage@gamebrief.gg",   password: "password123", username: "SniperSage",    avatar_url: "https://randomuser.me/api/portraits/men/22.jpg",    follower_count: 19400)
upsert_user(email: "nightowlnova@gamebrief.gg", password: "password123", username: "NightOwlNova",  avatar_url: "https://randomuser.me/api/portraits/women/28.jpg",  follower_count: 17800)
upsert_user(email: "vortexking@gamebrief.gg",   password: "password123", username: "VortexKing",    avatar_url: "https://randomuser.me/api/portraits/men/32.jpg",    follower_count: 15200)
upsert_user(email: "glitchhunter@gamebrief.gg", password: "password123", username: "GlitchHunter",  avatar_url: "https://randomuser.me/api/portraits/men/55.jpg",    follower_count: 12600)
upsert_user(email: "crystalrift@gamebrief.gg",  password: "password123", username: "CrystalRift",   avatar_url: "https://randomuser.me/api/portraits/women/50.jpg",  follower_count: 10900)
upsert_user(email: "apexdaddy@gamebrief.gg",    password: "password123", username: "ApexDaddy",     avatar_url: "https://randomuser.me/api/portraits/men/65.jpg",    follower_count: 8500)

puts "Cleaning up orphaned game records..."
Game.where(name: "Ragnarok: War of Gods").destroy_all

puts "Importing games from IGDB..."

client = IgdbClient.new

def import_game(client, query, free_to_play: false, single_player: false, multiplayer: false)
  results = client.search_games(query)
  match = results.find { |g| g["name"]&.downcase == query.downcase && g["cover"] }
  match ||= results.find { |g| g["cover"] }
  match ||= results.first
  return nil unless match

  cover_url = match["cover"] ? "https:#{match["cover"]["url"].gsub("t_thumb", "t_cover_big")}" : nil

  game = Game.where("LOWER(name) = ?", query.downcase).first
  game ||= Game.find_by(slug: match["slug"]) if match["slug"].present?
  game ||= Game.new

  game.update!(
    name: match["name"],
    slug: match["slug"],
    cover_image: cover_url,
    free_to_play: free_to_play,
    single_player: single_player,
    multiplayer: multiplayer
  )

  game
end

fortnite  = import_game(client, "Fortnite", free_to_play: true, multiplayer: true)
warzone   = import_game(client, "Call of Duty: Warzone", free_to_play: true, multiplayer: true)
apex      = import_game(client, "Apex Legends", free_to_play: true, multiplayer: true)
destiny   = import_game(client, "Destiny 2", free_to_play: false, single_player: true, multiplayer: true)
fifa      = import_game(client, "EA Sports FC 26", free_to_play: false, single_player: true, multiplayer: true)
roblox    = import_game(client, "Roblox", free_to_play: true, single_player: true, multiplayer: true)
clash     = import_game(client, "Clash Royale", free_to_play: true, multiplayer: true)
coc       = import_game(client, "Clash of Clans", free_to_play: true, multiplayer: true)
minecraft = import_game(client, "Minecraft", free_to_play: false, single_player: true, multiplayer: true)
valorant  = import_game(client, "Valorant", free_to_play: true, multiplayer: true)
marvel    = import_game(client, "Marvel Rivals", free_to_play: true, multiplayer: true)
helldivers = import_game(client, "Helldivers 2", free_to_play: false, multiplayer: true)
overwatch2    = import_game(client, "Overwatch 2", free_to_play: true, multiplayer: true)
re_requiem    = import_game(client, "Resident Evil Requiem", free_to_play: false, single_player: true)
pokemon_pokopia = import_game(client, "Pokémon Pokopia", free_to_play: false, single_player: true)
battlefront2  = import_game(client, "Star Wars Battlefront II", free_to_play: false, single_player: true, multiplayer: true)
horizon_fw    = import_game(client, "Horizon Forbidden West", free_to_play: false, single_player: true)
ff7_rebirth   = import_game(client, "Final Fantasy VII Rebirth", free_to_play: false, single_player: true)
spiderman2    = import_game(client, "Marvel's Spider-Man 2", free_to_play: false, single_player: true)
gta_online    = import_game(client, "Grand Theft Auto V", free_to_play: false, single_player: true, multiplayer: true)
lol           = import_game(client, "League of Legends", free_to_play: true, multiplayer: true)
cyberpunk     = import_game(client, "Cyberpunk 2077", free_to_play: false, single_player: true)
space_marine2 = import_game(client, "Warhammer 40,000: Space Marine 2", free_to_play: false, single_player: true, multiplayer: true)
twoxko        = import_game(client, "2XKO", free_to_play: true, multiplayer: true)
genshin       = import_game(client, "Genshin Impact", free_to_play: true, single_player: true, multiplayer: true)
cs2           = import_game(client, "Counter-Strike 2", free_to_play: true, multiplayer: true)
dota2         = import_game(client, "Dota 2", free_to_play: true, multiplayer: true)
baldurs_gate3 = import_game(client, "Baldur's Gate 3", free_to_play: false, single_player: true, multiplayer: true)
pubg          = import_game(client, "PUBG: Battlegrounds", free_to_play: true, multiplayer: true)
battlefield6  = import_game(client, "Battlefield 6", free_to_play: false, single_player: true, multiplayer: true)

puts "Setting game genres..."

genre_map = {
  fortnite   => ["Battle Royale", "Shooter"],
  warzone    => ["Shooter", "Battle Royale"],
  apex       => ["Battle Royale", "Shooter"],
  destiny    => ["Shooter"],
  fifa       => ["Sports", "Simulation"],
  roblox     => ["Sandbox", "Simulation"],
  clash      => ["Mobile", "Strategy"],
  coc        => ["Mobile", "Strategy"],
  minecraft  => ["Sandbox", "Simulation"],
  valorant   => ["Shooter", "Strategy"],
  marvel        => ["Shooter"],
  helldivers    => ["Shooter"],
  overwatch2      => ["Shooter"],
  re_requiem      => ["Action", "Horror"],
  pokemon_pokopia => ["RPG"],
  battlefront2    => ["Shooter", "Action"],
  horizon_fw    => ["Action", "RPG"],
  ff7_rebirth   => ["RPG", "Action"],
  spiderman2    => ["Action", "Adventure"],
  gta_online    => ["Action", "Sandbox"],
  lol           => ["Strategy", "MOBA"],
  cyberpunk     => ["RPG", "Action"],
  space_marine2 => ["Action", "Shooter"],
  twoxko        => ["Fighting"],
  genshin       => ["RPG", "Action"],
  cs2           => ["Shooter", "Strategy"],
  dota2         => ["Strategy", "MOBA"],
  baldurs_gate3 => ["RPG"],
  pubg          => ["Battle Royale", "Shooter"],
  battlefield6  => ["Shooter", "Action"]
}

genre_map.each do |game, genres|
  next unless game
  pg_array = "{" + genres.map { |g| "\"#{g}\"" }.join(",") + "}"
  ActiveRecord::Base.connection.execute("UPDATE games SET genre = '#{pg_array}' WHERE id = #{game.id}")
end

puts "Creating patches..."

fortnite_patch = seed_placeholder_patch(
  game: fortnite,
  title: "Chapter 6 Balance Update",
  content: <<~TEXT,
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
  summaries: {
    "quick_summary" => "Guns feel a bit more accurate this patch — ARs got a damage boost and bloom was reduced so your shots land more consistently. Two new named locations dropped in the northwest, so expect hot drops there early on. Shotguns got a slight nerf at the top end, so don't rely on one-pumping as much.",
    "casual_impact" => "If you mainly build and fight, you'll notice ARs feeling a bit snappier and more reliable. Two new areas to explore give you fresh drop spots to try. Shotgun players may need to adjust — the big one-shot potential is slightly reduced.",
    "should_i_log_in" => "Yes — two brand new named locations dropped and the weapon meta shifted, so it's a good week to jump in and explore the map changes before everyone figures out the new meta."
  }
)

warzone_patch = seed_placeholder_patch(
  game: warzone,
  title: "Season 4 Weapon Tuning",
  content: <<~TEXT,
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
  summaries: {
    "quick_summary" => "The MTZ-556 AR got a range buff making it stronger at distance, while the Striker 9 SMG was pulled back to stop it dominating at longer ranges. Slide cancelling is slightly slower so movement feels less frantic. The Gulag got refreshed with a rotating weapon pool which keeps close quarters matches feeling fresh.",
    "casual_impact" => "Movement feels a little less chaotic now that slide cancelling is toned down, which may help if you struggle against hyper-aggressive players. The Gulag has fresh weapons so those second-chance fights feel less predictable. No drastic meta shift — your favourite loadout probably still works.",
    "should_i_log_in" => "If you play casually, sure — the Gulag refresh keeps things interesting and nothing was broken so badly that the game feels unfair. Don't rush back just for this patch though."
  }
)

apex_patch = seed_placeholder_patch(
  game: apex,
  title: "Mid-Season Update",
  content: <<~TEXT,
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
  summaries: {
    "quick_summary" => "Bloodhound and Wraith got buffed — Wraith's void ability is up more often and Bloodhound scans a bit further. Gibraltar took hits to both his dome cooldown and gun shield so he's a little weaker this patch. The new Squad Royale LTM is worth trying if you want a chaotic team mode with cosmetic rewards.",
    "casual_impact" => "If you play Wraith, you'll notice her escape is available more often which feels great in tough spots. Gibraltar mains may feel slightly squishier but the difference is small in casual play. The new Squad Royale mode is a fun change of pace if you want something less sweaty.",
    "should_i_log_in" => "Yes — the Squad Royale LTM is only available for 2 weeks and has exclusive cosmetic rewards. It's a fun, lower-pressure way to play and well worth a few sessions."
  }
)

destiny_patch = seed_placeholder_patch(
  game: destiny,
  title: "Season of Echoes Update",
  content: <<~TEXT,
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
  summaries: {
    "quick_summary" => "Big patch this season — there's a brand new raid called the Vault of Fractured Light plus a fresh set of craftable seasonal weapons. Solar and Void builds got small buffs so if you've been running those subclasses you'll feel stronger. Stasis shatter got toned down in higher-end content so pure Stasis builds may want to adjust.",
    "casual_impact" => "There's a lot of new content to sink your teeth into — a new raid, new weapons to chase, and a fresh artifact to level up. If you play Solar or Void casually you'll feel slightly stronger without needing to change anything. Stasis players in endgame content may want to experiment with alternatives.",
    "should_i_log_in" => "Absolutely yes — new raid, new craftable weapons, and a seasonal artifact make this one of the bigger patches of the year. Even if you only play a few hours a week there's plenty of new content to enjoy."
  }
)

fifa_patch = seed_placeholder_patch(
  game: fifa,
  title: "Title Update 10 — FUT Balance",
  content: <<~TEXT,
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
  summaries: {
    "quick_summary" => "Pack weights are temporarily boosted around Team of the Season so it's a good time to open packs if you've been saving. Heading has been toned down for weaker players and through ball defending is more consistent, which should reduce some frustrating goals. FUT Champions now rewards points more fairly for lower win counts.",
    "casual_impact" => "Gameplay feels slightly more consistent — fewer cheap goals from headers and lobbed through balls. If you play FUT Champions occasionally, you'll earn more points even from losses which makes weekend league less punishing. If you've been hoarding packs, now's the time to open them.",
    "should_i_log_in" => "Yes if you play FUT — Team of the Season pack weights are boosted right now which is the best time to open packs all year. Even if you don't spend coins, the gameplay improvements make matches feel a bit less frustrating."
  }
)

roblox_patch = seed_placeholder_patch(
  game: roblox,
  title: "Engine Update — Physics & Performance",
  content: <<~TEXT,
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
  summaries: {
    "quick_summary" => "A performance-focused update — loading times are roughly 15% faster and mobile devices should crash less often in busy servers. Layered clothing now supports 8 layers so you can style your avatar even more. Developers get a new flame graph profiler tool to help track down lag in their games.",
    "casual_impact" => "Games load noticeably faster and your experience should be smoother, especially on mobile. You can now layer even more clothing items on your avatar for more creative outfits. Nothing gameplay-changing — this is a quality of life patch.",
    "should_i_log_in" => "Only if you were already planning to — this is a background improvements patch with no major new content. The performance boost is welcome but not a reason to rush back on its own."
  }
)

clash_patch = seed_placeholder_patch(
  game: clash,
  title: "Balance Update — Card Adjustments",
  content: <<~TEXT,
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
  summaries: {
    "quick_summary" => "Goblin Giant and Dark Prince got some love this patch with hitpoint and shield buffs, making them more viable in ladder. Evo Firecracker lost her death split when evolved which was a significant nerf to one of the most popular evolutions. A new Evo Cannon Cart is coming in Season 52 with a speed burst after its cart is destroyed.",
    "casual_impact" => "If you've been using Evo Firecracker, her death split is gone when evolved so she feels less explosive. Goblin Giant decks become more viable which could shake up what you face on ladder. Season 52 is close and brings a new Evo to try out.",
    "should_i_log_in" => "Worth checking in — the Evo Firecracker nerf shakes up a dominant deck and Season 52 starts soon with new content. If you like keeping up with the meta, now's a good time to experiment with alternatives."
  }
)

coc_patch = seed_placeholder_patch(
  game: coc,
  title: "Spring 2025 Balance Update",
  content: <<~TEXT,
    Town Hall 17
    - Loot Cart now collects 20% more resources from attacks (up from 15%).
    - Hero Equipment: Barbarian Puppet equipment level cap increased to 27.

    Troop Balancing
    - Super Witch: Summoned Big Boy hitpoints increased by 8%.
    - Druid: Heal radius increased from 4 to 4.5 tiles.
    - Minion Prince: Dark Elixir cost reduced from 160 to 140 per training.
    - Root Rider: Movement speed reduced from 24 to 22.

    Defence Balancing
    - Scattershot: Projectile speed increased. Now hits air troops 15% faster.
    - Ricochet Cannon: Bounce damage reduced by 6% to reduce dominance at TH16.
    - Monolith: Soul-stealing damage reduced at lower levels (levels 1-2 affected).

    Clan Wars
    - War loot bonus increased by 10% for Clan War League Gold and Crystal leagues.
    - Friendly challenges now show live troop deployment during replays.

    Bug Fixes
    - Fixed Builder Base troops sometimes freezing mid-attack on certain layouts.
    - Resolved issue where Clan Capital raid medals were not being awarded correctly after a disconnect.
  TEXT
  summaries: {
    "quick_summary" => "The Druid and Super Witch got buffed this patch making them stronger offensive options, while the Root Rider was slowed down to stop it being too dominant. Defences got tweaked too — the Scattershot hits air troops faster and the Ricochet Cannon was toned down at TH16. Clan War League loot went up by 10% so it's a good time to stay active in wars.",
    "casual_impact" => "Your attacks might feel different — Root Rider pushes slower now so you need to adjust timing. Druid and Super Witch are better options if you have them unlocked. The 10% Clan War League loot boost means you earn more just by participating normally.",
    "should_i_log_in" => "Yes — Clan War League loot is up 10% this cycle so you get more rewards for the same effort. Worth logging in to take advantage even if you just play a few attacks."
  }
)

minecraft_patch = seed_placeholder_patch(
  game: minecraft,
  title: "Java Edition 1.21.4",
  content: <<~TEXT,
    New Features
    - Added the Pale Garden biome: a new eerie woodland with white birch-like trees and hanging moss.
    - Added the Creaking mob: a hostile creature that only moves when unobserved. Spawns in Pale Gardens at night.
    - Added the Creaking Heart block: found in Pale Oak trees. Acts as the source of a nearby Creaking.

    Changes
    - Pale Oak Wood is a new wood type with full block set: logs, planks, slabs, stairs, fences and doors.
    - Bundle item is now fully released (no longer experimental). Can hold up to 64 items of varying types.
    - Boat with Chest now has a slightly larger inventory (increased from 27 to 36 slots).

    Technical Changes
    - New particle system improvements for better performance on lower-end hardware.
    - Chunk loading speed improved in multiplayer servers.

    Bug Fixes
    - Fixed Armadillo not rolling up when a player approached with a wolf nearby.
    - Resolved Breeze wind charge sometimes passing through solid blocks.
    - Fixed fishing rod occasionally failing to reel in entities.
  TEXT
  summaries: {
    "quick_summary" => "A big atmospheric update — the new Pale Garden biome is a creepy white forest that spawns the Creaking, a mob that only moves when you're not looking at it. Bundles are finally out of experimental and let you mix item types in one stack, which is a big quality of life win for inventory management. Pale Oak is a new full wood type so builders have a fresh block palette to work with.",
    "casual_impact" => "Exploring the world just got more interesting with a spooky new biome and a genuinely unsettling new mob. Bundles make managing your inventory much less painful — you can finally carry a mix of items in one slot. Builders get a beautiful new pale wood type to use in their creations.",
    "should_i_log_in" => "Yes — new biome, new mob, and bundles finally released are all worth exploring. Whether you like survival, building or just wandering, this patch has something for you."
  }
)

valorant_patch = seed_placeholder_patch(
  game: valorant,
  title: "Patch 10.04 — Agent & Map Updates",
  content: <<~TEXT,
    Agent Updates

    Gekko
    - Dizzy (Q): Blind duration reduced from 2.5s to 2.1s.
    - Wingman (E): Cost increased from 250 to 300 credits.

    Jett
    - Tailwind (E): Dash activation window reduced from 12s to 10s after activating.
    - Cloudburst (C): Duration reduced from 4.5s to 4s.

    Deadlock
    - Gravnet (Q): Cooldown reduced from 40s to 30s.
    - Barrier Mesh (E): Barrier segment health increased from 500 to 600.

    Iso
    - Double Tap (E): Shield health increased from 50 to 65.
    - Kill Contract (X): Ult points cost reduced from 8 to 7.

    Weapon Updates
    - Phantom: First bullet accuracy while moving slightly improved.
    - Operator: Scoping speed reduced by 5%.
    - Shorty: Damage falloff at max range reduced.

    Map Updates — Ascent
    - Mid top boxes adjusted to reduce one-way smoke positions.
    - A site: Cover on CT side adjusted for better balance.

    Bug Fixes
    - Fixed Viper's Pit not correctly applying decay to players entering from the edge.
    - Resolved Cypher camera sometimes persisting after Cypher is eliminated.
  TEXT
  summaries: {
    "quick_summary" => "Gekko and Jett got nerfed — Jett's dash window is shorter and Gekko's blind doesn't last as long, so both are slightly less dominant in ranked. Deadlock got some love with a faster Gravnet cooldown and stronger barriers, making her more viable as a sentinel. The Phantom got a small accuracy buff while moving which could make it feel better in close-range fights.",
    "casual_impact" => "Jett feels a little less slippery now which may help if you struggle against her. Phantom users may notice it feeling more responsive when moving which is a small but noticeable improvement. Deadlock is more playable if you like sentinel roles.",
    "should_i_log_in" => "If you're already playing ranked, yes — the meta shifted slightly and Deadlock is more viable now which adds variety. No major map changes or new agents so it's not a must-play patch if you've been taking a break."
  }
)

marvel_patch = seed_placeholder_patch(
  game: marvel,
  title: "Season 1 Balance Patch",
  content: <<~TEXT,
    Hero Adjustments

    Buffs
    - Iron Man: Unibeam charge rate increased by 10%. Armor health increased from 250 to 275.
    - Rocket Raccoon: Jetpack Dash cooldown reduced from 8s to 6s.
    - Luna Snow: Healing output of Ice Arts passive increased by 8%.
    - Squirrel Girl: Burst of Squirrels projectile speed increased.

    Nerfs
    - Hela: Nightsword Throw damage reduced from 65 to 58.
    - Jeff the Land Shark: It's Jeff ultimate radius reduced by 10%.
    - Magneto: Metal Bulwark shield duration reduced from 3s to 2.5s.
    - Spider-Man: Web-Swing speed reduced slightly to reduce rotation dominance.

    New Content
    - Mister Fantastic added to the roster. Available now via unlock or direct purchase.
    - Invisible Woman added to the roster. Releases mid-season.
    - New map: Midtown Manhattan added to Quick Match rotation.

    Ranked Mode
    - Placement matches now require 10 games (up from 5) for more accurate initial ranking.
    - Diamond rank split into Diamond I and Diamond II.

    Bug Fixes
    - Fixed Storm's Lightning Surge sometimes dealing no damage on hit.
    - Resolved Cloak & Dagger Team-Up ability not triggering correctly when both heroes were alive.
  TEXT
  summaries: {
    "quick_summary" => "Hela and Jeff the Land Shark were both nerfed — Hela hits a bit softer and Jeff's ultimate covers less ground, so both are less oppressive to play against. Iron Man and Rocket Raccoon got buffed and should feel more impactful this season. Mister Fantastic is now available to unlock and Invisible Woman is coming mid-season, so the roster keeps growing.",
    "casual_impact" => "Matches should feel a bit less one-sided now that Hela and Jeff are toned down — two of the most complained-about characters got reined in. Iron Man feels stronger if you like playing him. Two new heroes arrive this season giving you more options to try.",
    "should_i_log_in" => "Yes — Mister Fantastic is now playable and Invisible Woman arrives mid-season, making this a great time to come back and try new heroes. The balance changes also make the game feel fairer which helps casual players."
  }
)

helldivers_patch = seed_placeholder_patch(
  game: helldivers,
  title: "Patch 01.002.200 — Escalation of Freedom",
  content: <<~TEXT,
    New Content
    - New enemy faction: the Illuminate have returned to the galaxy. Available on select planets.
    - New stratagem: Tesla Tower — an area-denial electric turret effective against grouped infantry.
    - New primary weapon: Adjudicator Rifle — a medium-calibre assault rifle with armour-piercing rounds.

    Weapon Balancing
    - Railgun: Unsafe mode damage increased by 12%. Safe mode unchanged.
    - Eruptor: Explosion radius slightly reduced to prevent frequent self-damage.
    - Flamethrower: Damage per second increased by 15%. Fuel capacity reduced by 10%.
    - Anti-Materiel Rifle: Reload time reduced from 4s to 3.5s.

    Stratagem Updates
    - Eagle Airstrike: Cooldown reduced from 120s to 110s.
    - Orbital Laser: Duration increased by 20%. Cooldown increased from 300s to 360s.
    - Shield Generator Relay: Radius increased slightly.

    Enemy Changes
    - Automaton Hulk: Weak point hit detection improved — back vents now register more consistently.
    - Bile Titan: Headshot damage multiplier increased. Easier to kill with precision weapons.
    - Illuminate Voteless: New basic enemy. Low health, moves in large swarms.

    Bug Fixes
    - Fixed Hellpod landing occasionally dealing friendly fire damage through terrain.
    - Resolved mission objective markers disappearing after a host migration.
    - Fixed some stratagems not being callable near certain map edges.
  TEXT
  summaries: {
    "quick_summary" => "The Illuminate are back as a third enemy faction which adds a fresh challenge on certain planets. Railgun got a meaningful buff in unsafe mode so it's worth experimenting with again, and the Flamethrower now deals more damage but carries less fuel. A new Tesla Tower stratagem has been added for area control and is great against the new Voteless swarm enemies.",
    "casual_impact" => "You'll face a brand new enemy type — the Illuminate Voteless come in large swarms and play completely differently from bugs or robots. The Flamethrower hits harder but you'll burn through ammo faster. Bring the new Tesla Tower for the swarm missions — it's very effective.",
    "should_i_log_in" => "Absolutely yes — a new enemy faction is one of the biggest additions the game can get. The Illuminate missions feel fresh and different, and there's a Major Order active with bonus rewards. Don't miss this one."
  }
)

overwatch2_patch = seed_placeholder_patch(
  game: overwatch2,
  title: "Season 16 — Rivalry Update",
  content: <<~TEXT,
    New Season Content
    - New hero: Freja added as a Damage role hero. A ranged hunter with a crossbow and tracking abilities.
    - New map: Esperança — a Portuguese coastal city with tight alleyways and open plazas added to Push and Quick Play rotations.
    - New seasonal Battle Pass with 80 tiers of cosmetics including 2 Legendary skins per role.

    Hero Balance

    Buffs
    - Ana: Biotic Rifle healing increased from 75 to 80. Sleep Dart cooldown reduced from 15s to 14s.
    - Symmetra: Turret placement range increased. Photon Barrier width increased by 10%.
    - Roadhog: Chain Hook range increased from 20m to 22m.

    Nerfs
    - Tracer: Pulse Bomb damage reduced from 400 to 370.
    - Venture: Drill Dash cooldown increased from 6s to 7s.
    - Illari: Captive Sun ultimate radius reduced by 8%.

    Map Updates
    - King's Row: Added new flanking route through the bookshop on Point A approach.
    - Lijiang Tower: Night Market lighting updated for improved visibility.

    Bug Fixes
    - Fixed Junker Queen's Commanding Shout sometimes not applying to nearby allies behind geometry.
    - Resolved Freja's tracking ability occasionally locking onto eliminated targets.
    - Fixed stat tracker not displaying correctly for new heroes during their first season.
  TEXT
  summaries: {
    "quick_summary" => "Season 16 brings a brand new hero — Freja, a crossbow damage dealer with tracking abilities — alongside a new Push map set in Portugal. Tracer got nerfed with a weaker Pulse Bomb, while Ana feels stronger with better healing output and a faster Sleep Dart. A full new Battle Pass rounds out the season content.",
    "casual_impact" => "Freja is a fun new hero to try if you like ranged damage playstyles. Tracer is slightly less threatening in casual modes which helps if you struggle against her. Esperança is a beautiful new map worth exploring in Quick Play before it hits competitive.",
    "should_i_log_in" => "Yes — a new hero and new map are the highlights of any Overwatch season and both are worth experiencing fresh. Even if you only play a few matches a week, Season 16 has enough new content to make it worth jumping back in."
  }
)

re_requiem_patch = seed_placeholder_patch(
  game: re_requiem,
  title: "Title Update 1.02 — Performance & Encounter Fixes",
  content: <<~TEXT,
    Gameplay Adjustments
    - Knife durability increased by 20% across all knife types to reduce early-game frustration.
    - Heal item crafting speed reduced slightly to balance pacing in Hardcore difficulty.
    - New encounter added in the old hospital section — adjusted enemy patrol routes in Chapter 3.

    Combat Tuning
    - Stagger threshold for standard enemies slightly reduced — more shots required to stagger reliably.
    - Explosive barrels now deal splash damage to breakable props within 3m.
    - Parry window on charged enemy attacks extended by 2 frames for improved responsiveness.

    Performance
    - Ray tracing stability improved on PS5 and Series X — reduced flickering in reflective surfaces.
    - Frame pacing improved in Performance Mode on last-gen hardware.
    - Loading times between map zones reduced by approximately 12%.

    Bug Fixes
    - Fixed a progression block where the laboratory keycard door would not open after a specific cutscene.
    - Resolved an issue where enemy audio cues would not play after reloading a checkpoint.
    - Fixed inventory UI sometimes displaying incorrect item quantities after crafting.
  TEXT
  summaries: {
    "quick_summary" => "A focused patch that smooths out some rough edges — knives last longer which helps a lot in early chapters, and the parry window is slightly more forgiving so aggressive play feels more rewarding. Performance Mode got improved frame pacing and a critical door bug that blocked progression has been fixed.",
    "casual_impact" => "If you were struggling with knife durability running out too fast in the opening chapters, this patch helps significantly. Load times are shorter and the game runs more smoothly on all platforms. The new hospital encounter adds a bit more tension if you're replaying the game.",
    "should_i_log_in" => "If you were blocked by the keycard bug — yes, start immediately. If you haven't started yet, this is the best version of the game to play. The performance improvements and balance tweaks make the experience noticeably smoother."
  }
)

pokemon_pokopia_patch = seed_placeholder_patch(
  game: pokemon_pokopia,
  title: "Version 1.1.0 — Festival of Seasons Update",
  content: <<~TEXT,
    New Content
    - Festival of Seasons event: A rotating 4-week in-game festival with themed activities, rare spawns, and exclusive cosmetic rewards for your trainer.
    - 12 new Pokémon added to the Pokopia regional Pokédex across all biomes.
    - New area unlocked: The Crystalline Caverns, accessible after completing the 5th Gym challenge.

    Battle System Updates
    - New move type interactions added: Prism-type moves introduced for select new Pokémon.
    - Double Battle AI improved in the post-game — opponents now use held items and switching more strategically.
    - Online ranked battles now use a separate matchmaking pool from casual battles.

    Quality of Life
    - Pokémon box now supports 40 boxes (up from 32).
    - Auto-save interval now configurable in settings (off / 5 min / 10 min / 30 min).
    - Held item preview added to battle summary screen.

    Bug Fixes
    - Fixed a crash when attempting to evolve a Pokémon with a full party during a cutscene.
    - Resolved incorrect shiny encounter rates in the Crystalline Caverns on launch.
    - Fixed trade evolution not completing correctly when the connection dropped mid-trade.
  TEXT
  summaries: {
    "quick_summary" => "The Festival of Seasons event is the big addition — it runs for 4 weeks and brings exclusive cosmetics, rare spawns, and themed activities. 12 new Pokémon have been added to the region's Pokédex and a brand new post-game area, the Crystalline Caverns, opens up after the 5th Gym. The new Prism-type move interactions add fresh depth to competitive battles.",
    "casual_impact" => "Even if you're mid-playthrough there are 12 new Pokémon to find and catch across the world. The box expansion to 40 boxes is a welcome change if you love collecting. The Festival event has limited-time cosmetics so it's worth logging in regularly over the next month.",
    "should_i_log_in" => "Yes — the Festival of Seasons is time-limited and the exclusive rewards won't come back easily. The new Pokémon and Crystalline Caverns give you more to explore whether you're just starting or already post-game."
  }
)

battlefront2_patch = seed_placeholder_patch(
  game: battlefront2,
  title: "The Age of Rebellion Update",
  content: <<~TEXT,
    New Content
    - New map: Scarif Beachhead added to all large-scale modes including Galactic Assault and Co-Op.
    - New hero: Jyn Erso added as a Rebel hero unit with two active abilities and one passive.
    - New villain: Director Krennic added as an Imperial villain unit.

    Hero & Villain Balance
    - Luke Skywalker: Rush ability cooldown reduced from 10s to 9s.
    - Darth Vader: Focused Rage bonus damage duration increased from 5s to 6s.
    - Rey: Insight passive detection range slightly reduced.
    - Boba Fett: Jetpack Boost fuel recovery rate increased by 10%.

    Class Adjustments
    - Officer: Battle Command ability radius increased from 8m to 10m.
    - Heavy: Ion Torpedo now deals 10% more damage to vehicles.
    - Specialist: Infiltration ability cloak duration reduced from 10s to 8s.

    Bug Fixes
    - Fixed Maul's Spin Attack sometimes passing through enemies without registering damage.
    - Resolved issue where Co-Op objectives would reset after a host migration.
    - Fixed Scarif Beachhead lighting artifacts on low settings.
  TEXT
  summaries: {
    "quick_summary" => "Scarif from Rogue One joins the map pool which adds one of the most visually distinctive battlegrounds in the game to Galactic Assault. Two new heroes arrive — Jyn Erso and Director Krennic — bringing the Rogue One cast into multiplayer. Class tweaks give the Officer and Heavy roles a bit more impact in large battles.",
    "casual_impact" => "Scarif is a gorgeous new map that plays differently to anything else in the roster, with beach terrain and tight corridors. Jyn Erso is a mobile and aggressive hero option if you enjoy Rebel playstyle. The Officer buff means support roles feel slightly more rewarding to play.",
    "should_i_log_in" => "Yes — Scarif and two new heroes are the kind of content drop that makes this game worth revisiting. Even if you haven't played in a while, this is a great excuse to jump back into Galactic Assault."
  }
)

horizon_fw_patch = seed_placeholder_patch(
  game: horizon_fw,
  title: "Update 1.21 — Burning Shores & Balance Pass",
  content: <<~TEXT,
    New Content
    - Burning Shores DLC: A new region set in a flooded post-apocalyptic Los Angeles. Features new machines, a new story, and a new companion.
    - New machine: Bilegut added to Burning Shores — a large amphibious creature with acid-based attacks.
    - New weapon: Specter Gauntlet added as a Burning Shores exclusive ranged weapon.

    Weapon & Gear Balance
    - Shredder Gauntlet: Charged disc damage increased by 10%.
    - Spike Thrower: Detonation radius on impact spikes slightly increased.
    - Boltblaster: Energy cell reload speed improved.
    - Shield-Weaver armour: Overcharge cooldown reduced from 30s to 25s.

    Machine Adjustments
    - Slitherfang: Coil shots now deal 5% less damage to compensate for frequent use in late-game builds.
    - Stormbird: Wingbeat knock-back radius slightly reduced.
    - Clawstrider: Overriding a Clawstrider is now 10% faster when using Override perks.

    Bug Fixes
    - Fixed a crash occurring when fast-travelling during a Cauldron cutscene.
    - Resolved an issue where machine overrides would break after reloading a save.
    - Fixed texture pop-in on Burning Shores coastal areas.
  TEXT
  summaries: {
    "quick_summary" => "Burning Shores is the major DLC addition — it sends Aloy to a flooded Los Angeles with new machines, weapons, and story content. The Shredder Gauntlet got a damage boost and Shield-Weaver armour recharges faster, giving endgame builds a bit more punch. A new Bilegut machine adds an acid-heavy challenge to the Burning Shores region.",
    "casual_impact" => "Burning Shores is a worthwhile expansion if you enjoyed the main game — it's a beautiful region with a distinct look and feel. The weapon buffs make mid-game gear feel more viable in late encounters so you don't need to constantly upgrade. Override builds got a small quality-of-life boost too.",
    "should_i_log_in" => "Yes if you have the DLC — Burning Shores is visually stunning and tells a standalone story worth experiencing. If you haven't finished the base game yet, there's also never been a better time to start."
  }
)

ff7_rebirth_patch = seed_placeholder_patch(
  game: ff7_rebirth,
  title: "Version 1.040 — Combat & Synergy Updates",
  content: <<~TEXT,
    Combat Adjustments
    - Cloud: Punisher Mode now builds stagger gauge 10% faster on counter-attacks.
    - Tifa: Unbridled Strength stacks now persist for 5 additional seconds before resetting.
    - Aerith: Tempest casting speed increased. ATB charge from Ward Shift improved.
    - Barret: Overcharge now deals 8% more damage at max gauge.
    - Red XIII: Vengeance Mode duration increased from 20s to 22s.

    Synergy Abilities
    - Cloud + Tifa: Synergy Skill cooldown reduced from 90s to 80s.
    - Aerith + Red XIII: Bloom damage radius increased.
    - Barret + Yuffie: Chain Attack damage bonus increased by 5%.

    Materia & Equipment
    - New Materia: Comet — available from specific Moogle Emporium vendors post-Chapter 10.
    - New accessory: Champion Belt added to Hard Mode endgame rewards.
    - Elemental Materia now pairs correctly with all weapon slots on Aerith's rods.

    Bug Fixes
    - Fixed a rare issue where some Chapter Select saves would not carry over correct party equipment.
    - Resolved Chadley's Battle Simulator progress sometimes not saving after a crash.
    - Fixed an issue where music tracks would not transition correctly during certain boss encounters.
  TEXT
  summaries: {
    "quick_summary" => "A solid combat-focused patch — Tifa's stacks last longer and Cloud staggers enemies faster in Punisher Mode, making both feel more rewarding to play. Synergy Skill cooldowns are down across the board so co-op moves flow better in longer fights. New Comet Materia adds a magic option for those building elemental party comps.",
    "casual_impact" => "If you play on Normal mode you'll notice combat feeling slightly smoother, especially with Tifa and Cloud combos. Synergy abilities come up more often now which makes battles more dynamic without needing to grind for new gear. The new Materia is worth picking up if you're in the late game.",
    "should_i_log_in" => "If you've been meaning to start or continue — yes. The combat feels more polished than ever and the new Materia adds fresh build options. For players who have already finished, Hard Mode endgame got new rewards worth grinding for."
  }
)

spiderman2_patch = seed_placeholder_patch(
  game: spiderman2,
  title: "Update 1.003.001 — New Game+ & Balance Pass",
  content: <<~TEXT,
    New Content
    - New Game+ added: Carry over all suits, gadgets, and upgrades from your completed save. New NG+ exclusive suits unlocked upon starting.
    - Ultimate difficulty added as part of New Game+.
    - New Trophy set added for New Game+ completion milestones.

    Combat Balance
    - Peter (Symbiote): Venom Punch damage increased by 8%. Symbiote Surge cooldown reduced by 5s.
    - Miles: Venom Dash now chains to a second enemy if the first is defeated within 1.5s.
    - Web Wings: Dive speed increased slightly for more satisfying aerial traversal.
    - Gadgets: Web Grabber pull radius increased to catch more grouped enemies.

    Suit Tech Adjustments
    - Focus Generation: Passive rate increased slightly across all combat suits.
    - Symbiote Tendrils (Peter): Tendril damage reduced by 6% to rebalance endgame encounters.

    Bug Fixes
    - Fixed a crash triggered by switching characters rapidly during a specific main mission cutscene.
    - Resolved an issue where photo mode filters were not saving correctly between sessions.
    - Fixed suit colour variants not unlocking correctly for certain DLC suits.
  TEXT
  summaries: {
    "quick_summary" => "New Game+ is the headline addition — you carry everything over and unlock exclusive new suits while tackling an Ultimate difficulty mode. Miles got a nice combo buff where Venom Dash chains between enemies, and the Symbiote Surge for Peter is up more often. Web Wings diving feels snappier which makes traversal even more satisfying.",
    "casual_impact" => "If you've finished the story, New Game+ gives you a great reason to replay with all your upgrades intact and new suits to unlock. The combat tweaks make Miles feel a bit more fluid in combo chains. Traversal with the Web Wings is slightly more responsive which is a welcome quality of life improvement.",
    "should_i_log_in" => "Yes — New Game+ and Ultimate difficulty are significant additions that give completionists and challenge seekers a fresh goal. If you haven't played yet, now is the perfect time with all updates applied and the full experience available."
  }
)

gta_online_patch = seed_placeholder_patch(
  game: gta_online,
  title: "Bottom Dollar Bounties Update",
  content: <<~TEXT,
    New Content
    - New business: Bottom Dollar Bounties — a bounty hunting operation managed from a new property in Blaine County.
    - 3 new vehicles added: Declasse Impaler SX, Vapid Clique, and Declasse Vamos.
    - New weapons: Compact EMP Launcher and Precision Rifle added to Ammu-Nation.

    Business & Economy
    - Bottom Dollar Bounties contracts pay out between GTA$25,000 and GTA$85,000 depending on target difficulty.
    - Nightclub income passive generation increased by 10%.
    - Bunker research speed increased slightly for solo players.

    Vehicle Updates
    - New HSW upgrades available for 4 additional vehicles at the LS Car Meet.
    - Several older sports cars added to the Podium Vehicle rotation for the coming weeks.

    Quality of Life
    - CEO/VIP work cooldown timers reduced by 2 minutes across all mission types.
    - Improved matchmaking for Contact Missions on lower player count sessions.

    Bug Fixes
    - Fixed an issue where the Acid Lab delivery missions would fail to trigger correctly after a lobby change.
    - Resolved a rare freeze when entering the Agency building during a cutscene.
    - Fixed several floating prop issues in the new Blaine County property.
  TEXT
  summaries: {
    "quick_summary" => "The Bottom Dollar Bounties update adds a brand new business where you hunt down targets for cash payouts up to GTA$85K. Three stylish new classic-inspired vehicles landed alongside new weapons. Nightclub passive income got a bump and CEO cooldowns are shorter, making grinding feel slightly less repetitive.",
    "casual_impact" => "Bounty hunting is one of the more accessible new businesses — you can run it solo and the missions are varied. The CEO cooldown reduction means you can chain missions faster which helps if you only have short play sessions. The new vehicles are great for car collectors.",
    "should_i_log_in" => "Yes — Bottom Dollar Bounties is a fun new activity with solid payouts and the new vehicles alone are worth logging in for. If you've been away for a while, this is one of the more content-rich updates of recent months."
  }
)

lol_patch = seed_placeholder_patch(
  game: lol,
  title: "Patch 14.12 — Durability & Item Adjustments",
  content: <<~TEXT,
    Champion Balance

    Buffs
    - Jinx: Rocket damage increased at max stacks. Fishbones passive range slightly extended.
    - Orianna: Ball movement speed increased. Command: Shockwave cooldown reduced from 110s to 100s.
    - Renekton: Cull the Meek healing increased by 5% in empowered form.
    - Ivern: Rootcaller root duration increased from 1.5s to 1.7s.

    Nerfs
    - Yone: Soul Unbound dash speed slightly reduced to lower escape consistency.
    - Smolder: Dragon Practice stacks reduced from 225 to 200 for super charge.
    - Varus: Blighted Quiver max stack damage reduced by 4%.

    Item Changes
    - Heartsteel: Bonus health per stack reduced from 5 to 4 HP. Cap unchanged.
    - Sundered Sky: Lifeline passive shield slightly increased.
    - Bloodthirster: AD reduced by 5 but lifesteal increased by 2%.

    Durability Adjustments
    - Base armour increased by 2 for all supports.
    - Tenacity from Legend: Tenacity rune increased from 5% to 7% per stack.

    Ranked Changes
    - Split 3 begins with this patch. All players' LP adjusted to account for seasonal progression reset.
    - New ranked icon set introduced for Diamond and above.

    Bug Fixes
    - Fixed Orianna's Ball sometimes snapping to incorrect position after Flash.
    - Resolved Smolder's Achooo! not applying on-hit effects correctly on the first bounce.
  TEXT
  summaries: {
    "quick_summary" => "Split 3 kicks off with Patch 14.12 and a fresh ranked season reset. Jinx and Orianna got meaningful buffs — Orianna's ultimate is on a shorter cooldown which helps a lot in teamfights. Yone and Smolder were trimmed back as two of the stronger carries in recent patches. Supports get a small base armour bump which helps survivability in lane.",
    "casual_impact" => "If you play Orianna or Jinx you'll feel noticeably stronger this patch without changing anything. Yone is slightly less frustrating to play against. Split 3 starting means LP resets so now is a good time to push for a new rank without feeling behind.",
    "should_i_log_in" => "Yes — Split 3 just started which means everyone is climbing from a fresh baseline. It's the best time to push for your seasonal rank icon and the new Diamond cosmetics. Even casual players benefit from the clean slate."
  }
)

cyberpunk_patch = seed_placeholder_patch(
  game: cyberpunk,
  title: "Update 2.12 — Phantom Liberty Fixes & Tuning",
  content: <<~TEXT,
    Gameplay Adjustments
    - Cyberware capacity slots rebalanced — Legendary implants now cost 1 fewer slot than before.
    - Sandevistan activation speed improved for all tiers. MK.5 Sandevistan time dilation increased from 85% to 90%.
    - Mantis Blades: Heavy attack damage increased by 8%. Aerial finisher cooldown reduced.
    - Sonic Shock quickhack now correctly prevents enemies from calling for backup in all scenarios.

    Phantom Liberty
    - New gig added in Dogtown: The Afterimage — a multi-stage contract involving stolen BD recordings.
    - Two additional NCPD Scanner Hustles added to the northern Dogtown district.
    - Reed's safehouse now accessible post-story as a player apartment.

    Difficulty & Economy
    - Edgerunner difficulty slightly adjusted — Trauma Team response time increased from 45s to 55s.
    - Iconic weapon crafting costs reduced by 15% across all categories.
    - Ripperdoc prices reduced by 10% for Tier 4 and Tier 5 cyberware.

    Bug Fixes
    - Fixed a crash occurring when loading a save near the Corpo Plaza fast travel point.
    - Resolved an issue where the Temperance ending would not trigger correctly if a specific optional dialogue was skipped.
    - Fixed V's apartment radio stations not persisting after a game restart.
  TEXT
  summaries: {
    "quick_summary" => "Sandevistans got buffed — the MK.5 now slows time even more making it one of the best builds in the game. Cyberware slots are more generous for Legendary implants so you can fit more into your build without sacrificing as much. Phantom Liberty gets a new Dogtown gig and Reed's safehouse opens up as a post-story apartment.",
    "casual_impact" => "Iconic weapons and Tier 5 cyberware are cheaper to craft and buy, which makes endgame builds more accessible without hardcore grinding. The new Dogtown gig adds fresh content for players who have already finished the DLC. Mantis Blades players will notice a solid damage bump.",
    "should_i_log_in" => "Yes if you haven't finished Phantom Liberty — the new gig and apartment additions make Dogtown feel more lived-in. If you're starting fresh, this is the most polished the game has ever been and an excellent time to jump in."
  }
)

space_marine2_patch = seed_placeholder_patch(
  game: space_marine2,
  title: "Update 4.0 — Eternal War & PvP Overhaul",
  content: <<~TEXT,
    New Content
    - PvP mode: Eternal War returns with a full overhaul. Three new maps added: Iron Bastion, Relic Gate, and Ashfall Crossing.
    - New PvP chapter: Dark Angels playable in Eternal War with unique class cosmetics.
    - New Operations mission: The Reclamation — a 3-player co-op mission set in a corrupted forge world.

    Operations Balance
    - Bulwark: Shield bash stagger duration increased from 1.2s to 1.5s.
    - Vanguard: Grapnel Launcher cooldown reduced from 18s to 15s.
    - Heavy: Melta Charge explosion radius increased by 10%.
    - Assault: Jump Pack damage on landing increased by 8%.

    PvP Tuning
    - All bolt weapons: Damage falloff starts at slightly longer range.
    - Chainsword: Heavy attack speed increased to close the gap against ranged spam.
    - Class ability cooldowns reduced across the board by 5-10% in PvP.

    Progression
    - Chapter Requisition cap increased from 1500 to 2000.
    - New cosmetic tier: Artificer Armour unlocks added for all 6 classes at Chapter Master rank.

    Bug Fixes
    - Fixed Tyranid Carnifex sometimes not triggering its charge animation correctly.
    - Resolved an issue where co-op mission rewards would not appear after a host disconnect.
    - Fixed certain pauldron cosmetics clipping through capes on the Bulwark class.
  TEXT
  summaries: {
    "quick_summary" => "PvP Eternal War gets a major overhaul with three new maps and the Dark Angels chapter joining the roster. A new co-op Operations mission called The Reclamation adds fresh PvE content. The Vanguard got a nice buff with a shorter Grapnel cooldown and the Assault class hits harder on landing — both feel more impactful in firefights.",
    "casual_impact" => "If you mainly play co-op Operations, the new Reclamation mission is worth running and class buffs make every role feel a bit more capable. The Artificer Armour cosmetic tier gives long-term players a new prestige goal. PvP is now more polished if you've been avoiding it.",
    "should_i_log_in" => "Yes — this is one of the biggest updates the game has received. New PvP maps, a new chapter, and a new co-op mission all at once make this a great week to come back regardless of your preferred mode."
  }
)

twoxko_patch = seed_placeholder_patch(
  game: twoxko,
  title: "Open Beta Patch 0.8 — Roster & System Updates",
  content: <<~TEXT,
    New Champions
    - Illaoi added to the roster: A bruiser-style fighter with tentacle summons and arena control. Available now.
    - Ambessa added to the roster: A fast, aggressive duelist with combo-heavy pressure. Available now.

    Combat System
    - Tag mechanic adjusted: Tag-in invincibility window reduced from 12f to 9f to reward reads on unsafe tags.
    - Assist calls now have a 6-frame startup (up from 4f) for improved counterplay.
    - Wall splat recovery reduced by 4 frames — allows faster follow-ups after corner combos.

    Champion Adjustments
    - Jinx: Fishbones projectile hitbox width increased. Super Mega Death Rocket startup reduced by 3f.
    - Ekko: Time Winder on-hit detonation window extended by 2f.
    - Darius: Decimate pull range slightly reduced to limit neutral dominance.

    Ranked Mode
    - Season 1 begins with this patch. Placement matches reduced from 10 to 5 for returning beta players.
    - New rank tier: Void rank added above Masters for top 500 players on each server.

    Bug Fixes
    - Fixed Illaoi's tentacle summons persisting after a round reset in certain scenarios.
    - Resolved input buffer not registering correctly after a back dash on certain controllers.
    - Fixed ranked lobby sometimes showing incorrect opponent rank icons.
  TEXT
  summaries: {
    "quick_summary" => "Two big new champions arrive — Illaoi brings tentacle-based arena control and Ambessa is a fast combo-heavy duelist, both shaking up the meta immediately. The tag mechanic got tightened with less invincibility on tag-ins which rewards more reads. Season 1 ranked kicks off with this patch and adds a new Void tier for the top 500.",
    "casual_impact" => "Illaoi and Ambessa are both very fun to learn and play very differently from the existing roster — worth trying both in casual matches before ranked. Season 1 starting means your placement now matters, but the reduced placement count makes it less of a grind. Jinx mains will enjoy the improved Fishbones hitbox.",
    "should_i_log_in" => "Yes — Season 1 and two new champions in the same patch is the biggest moment in the game so far. Even if you've been waiting on the sidelines, now is the time to try the game and get your placement matches in before the season progresses."
  }
)

genshin_patch = seed_placeholder_patch(
  game: genshin,
  title: "Version 5.5 — Embers of the Dying Flame",
  content: <<~TEXT,
    New Content
    - New region: Natlan's Crimson Highlands added — a volcanic area with new puzzles, exploration mechanics, and 2 new Domains.
    - New 5-star character: Mavuika (Pyro, Claymore) — a high-damage DPS with an off-field fire summon.
    - New 4-star character: Kachina (Geo, Polearm) — a support with shield generation and energy recharge utility.
    - New weapon: Surf's Up — a 5-star Claymore with a Pyro damage bonus passive.

    Spiral Abyss Reset
    - New Spiral Abyss rotation with Pyro-resistant enemies in Floors 11 and 12.
    - Blessing of the Abyssal Moon: Increases Pyro DMG by 75% for all party members.

    Character Adjustments
    - Hu Tao: Stamina consumption during Charged Attacks reduced by 15%.
    - Cyno: Electro infusion during ultimate now persists for 1 additional second.
    - Dehya: Interruption resistance during skill increased to match heavier units.

    System Updates
    - Serenitea Pot storage expanded: Furnishing inventory cap increased from 300 to 400.
    - New co-op domain added to Natlan — supports parties of 1 to 4 players.

    Bug Fixes
    - Fixed Mavuika's flame summon persisting incorrectly after her burst ended.
    - Resolved a UI overlap when opening the character screen during a Pyro-infused attack.
  TEXT
  summaries: {
    "quick_summary" => "Version 5.5 opens the Crimson Highlands — a volcanic new area in Natlan with new domains and exploration mechanics. Mavuika is the headline 5-star, a hard-hitting Pyro DPS with an off-field summon that works well in reaction teams. The Spiral Abyss reset favours Pyro characters heavily this cycle so Mavuika and Hu Tao players are well positioned.",
    "casual_impact" => "The Crimson Highlands is a great area to explore even without the new characters — packed with puzzles and new Primogems to collect. Hu Tao feels slightly better to play with reduced stamina drain on her Charged Attacks. Kachina is an accessible 4-star support worth pulling from the banner if you need a Geo unit.",
    "should_i_log_in" => "Yes — new region means new exploration Primogems and a fresh Spiral Abyss rotation. Even if you're skipping Mavuika's banner, the Crimson Highlands alone is worth logging in to explore over the next few weeks."
  }
)

cs2_patch = seed_placeholder_patch(
  game: cs2,
  title: "Spring 2026 Update — Map Pool & Weapon Tuning",
  content: <<~TEXT,
    Map Pool Changes
    - Ancient removed from the Active Duty map pool. Replaced by Train (updated).
    - Train rework: Significant layout changes to A site and mid. Improved lighting and cover throughout.
    - Mirage: B apartments entry adjusted — one window angle removed to reduce defensive dominance.

    Weapon Tuning
    - AK-47: First shot accuracy while standing slightly improved.
    - M4A4: Magazine size increased from 30 to 32. Reload time unchanged.
    - AWP: Movement speed penalty while scoped increased by 5%.
    - Deagle: Hip fire accuracy reduced slightly at medium range.
    - MP9: Damage increased from 26 to 28.

    CS Rating & Premier
    - CS Rating decay removed for players below 10,000 rating.
    - End-of-season CS Rating rewards updated: new rank coins and sprays for reaching 15,000+.
    - Leaderboard regions split further — national leaderboards added for top 20 countries.

    Bug Fixes
    - Fixed a pixel walk on Inferno B site that allowed unintended positioning.
    - Resolved grenade trajectory preview occasionally flickering on high refresh rate monitors.
    - Fixed flashbang audio attenuation not applying correctly through walls.
  TEXT
  summaries: {
    "quick_summary" => "Train returns to the Active Duty pool replacing Ancient — a big shift for the competitive meta. The AK-47 got a first-shot accuracy buff making it more reliable at range, while the AWP is slightly slower when scoped so repositioning costs more. Premier rating decay below 10K is gone, which is a welcome relief for casual ranked players.",
    "casual_impact" => "If you play Premier casually, your rating won't decay anymore below 10K which removes a frustrating treadmill. Train is worth learning now that it's back in the pool — the rework makes it feel fresh. The MP9 buff makes it a more viable pistol-round buy if you like aggressive play.",
    "should_i_log_in" => "Yes — Train returning to Active Duty is one of the most significant meta shifts of the year and worth experiencing early before the community fully solves it. The rating decay removal also makes this a low-pressure time to push your rank."
  }
)

dota2_patch = seed_placeholder_patch(
  game: dota2,
  title: "Patch 7.37 — The Spring Equilibrium",
  content: <<~TEXT,
    General Changes
    - Roshan now spawns with a random buff active from a pool of 5 options — visible to both teams.
    - Outpost capture time reduced from 6s to 5s.
    - Bounty Runes now grant 40 gold (up from 30) and appear every 3 minutes (up from 5).

    Hero Adjustments

    Buffs
    - Invoker: Quas base damage increased. Exort orb damage scaling improved at levels 1-3.
    - Phantom Assassin: Blur evasion increased from 15/20/25/30% to 20/25/30/35%.
    - Tidehunter: Anchor Smash cooldown reduced from 12s to 10s.
    - Chen: Holy Persuasion now works on Ancient neutral creeps at level 4.

    Nerfs
    - Muerta: Dead Shot slow duration reduced from 3s to 2.5s.
    - Primal Beast: Onslaught cooldown increased by 2s at all levels.
    - Viper: Corrosive Skin feedback damage reduced by 10%.

    Item Changes
    - Aghanim's Scepter recipe cost reduced from 1200 to 1000 gold.
    - Black King Bar duration at level 1 increased from 9s to 10s.
    - Daedalus: Critical strike chance increased from 30% to 32%.

    Bug Fixes
    - Fixed Invoker's Tornado not correctly lifting units affected by Root.
    - Resolved a rare case where Roshan's Aegis timer would display incorrectly for one team.
  TEXT
  summaries: {
    "quick_summary" => "Patch 7.37 shakes up the early game with more frequent Bounty Runes that pay out more gold, making the first 10 minutes more active. Phantom Assassin gets a significant evasion buff making her harder to kill in drawn-out fights. Muerta and Primal Beast were reined in after dominating recent patches.",
    "casual_impact" => "Bounty Runes coming every 3 minutes makes map awareness more rewarding early on — grabbing them consistently matters more now. Aghanim's Scepter is 200 gold cheaper which helps every hero that needs it. Phantom Assassin is a strong carry pick this patch if you're looking for something new to try.",
    "should_i_log_in" => "Yes — 7.37 is a meaningful meta shift with hero balance changes across the board and a new Roshan mechanic that adds variety to every game. Whether you're a returning player or playing regularly, this patch freshens things up nicely."
  }
)

baldurs_gate3_patch = seed_placeholder_patch(
  game: baldurs_gate3,
  title: "Patch 8 — Photo Mode & Quality of Life",
  content: <<~TEXT,
    New Features
    - Photo Mode added: Pause the game at any point and capture cinematic screenshots with full camera control, filters, and depth of field adjustments.
    - New evil ending epilogue added: Extended conclusion scenes for Dark Urge and full evil playthroughs.
    - Honour Mode additions: 4 new Legendary Actions added to late-game bosses.

    Class & Balance Adjustments
    - Paladin: Lay on Hands now correctly applies to summons as well as party members.
    - Sorcerer: Wild Magic Surge table expanded with 8 new possible outcomes.
    - Monk: Flurry of Blows now consumes 1 Ki point instead of 2 at level 5+.
    - Rogue: Uncanny Dodge now correctly triggers on AoE saves as well as targeted attacks.

    Quality of Life
    - Camp supplies now stack to 99 (up from 40).
    - Inventory sorting improved — new filters for spell scrolls, potions, and quest items.
    - Fast travel menu now shows which areas have undiscovered content nearby.

    Bug Fixes
    - Fixed a dialogue skip in Act 3 that could lock players out of the Gortash confrontation.
    - Resolved camp ambush events occasionally triggering twice in the same rest.
    - Fixed certain hair physics clipping through helmets in cutscenes.
  TEXT
  summaries: {
    "quick_summary" => "Photo Mode is the headline addition — you can now capture stunning shots at any point in the game with full camera control. The evil ending epilogue is expanded with new scenes for Dark Urge playthroughs, and Honour Mode gets 4 new Legendary Actions on late bosses to raise the challenge further. Monk gets a solid quality of life buff with cheaper Flurry of Blows at higher levels.",
    "casual_impact" => "Camp supplies stacking to 99 is a small but welcome change that reduces inventory juggling. The fast travel map now hints at undiscovered content nearby which helps completionists find everything without a guide. Monk players will notice their Ki economy feeling much better in longer fights.",
    "should_i_log_in" => "Yes — the evil ending expansion and Photo Mode give returning players new reasons to replay. If you haven't finished the game yet, this is the most complete and polished version so far. Honour Mode veterans have new Legendary Actions to prepare for."
  }
)

pubg_patch = seed_placeholder_patch(
  game: pubg,
  title: "Update 32.1 — Rondo & Ranked Season 32",
  content: <<~TEXT,
    New Content
    - New map: Rondo — a 8x8 dense urban map set in a fictional East Asian city. Features destructible facades and multi-floor building combat.
    - New vehicle: Armoured SUV — a slow but heavily protected vehicle that seats 4. Spawns rarely on Rondo.
    - New throwable: Smoke Cluster Grenade — deploys 3 smaller smoke grenades in a spread pattern on impact.

    Weapon Tuning
    - M416: Horizontal recoil slightly reduced. Remains the most accessible AR.
    - Beryl M762: Damage per bullet reduced from 47 to 45 to reduce burst dominance.
    - SLR: Bullet velocity increased by 50m/s.
    - MP5K: Now spawns on Rondo as a world drop in addition to crate loot.

    Ranked Season 32
    - Season 32 begins with this update. Previous season rank rewards distributed.
    - New rank: Conqueror Apex added above Conqueror for top 500 players per region.
    - Ranked now supports solo and duo modes in addition to squad.

    Quality of Life
    - Ping system expanded — 3 new ping types added: Loot Here, Danger, and Move Out.
    - Replay system improved with better camera controls and a new free-cam mode.

    Bug Fixes
    - Fixed players occasionally clipping through Rondo building floors during rapid drops.
    - Resolved hit registration desync in high-latency lobbies.
    - Fixed the Armoured SUV engine audio not playing at low graphic settings.
  TEXT
  summaries: {
    "quick_summary" => "Rondo is the big new addition — a dense urban 8x8 map with destructible buildings that plays completely differently from Erangel or Miramar. The Beryl M762 was nerfed with lower damage per bullet, while the SLR got a bullet velocity buff making it stronger at range. Ranked Season 32 starts now with solo and duo modes added to ranked for the first time.",
    "casual_impact" => "Rondo is worth dropping into immediately — the dense city layout makes for intense close-range fights with lots of vertical play. The new Smoke Cluster Grenade is a great tool for casual players who want more cover options without needing precise throws. Solo ranked is finally available if squad play isn't your thing.",
    "should_i_log_in" => "Yes — a brand new map is the biggest content drop PUBG can deliver. Rondo plays like nothing else in the map pool and Season 32 starting means fresh ranked placement. Well worth jumping in this week."
  }
)

battlefield6_patch = seed_placeholder_patch(
  game: battlefield6,
  title: "Season 2 — Steel Horizon Update",
  content: <<~TEXT,
    New Content
    - New map: North Sea Platform — an offshore oil rig map with multi-level vertical combat and destructible structures. Available in Conquest and Breakthrough.
    - New specialist: Ikaika Kaimana — a Recon specialist with a passive sonar pulse and an active drone jammer ability.
    - New vehicle: AH-64E Apache — added to select maps as a rare vehicle spawn.

    Weapon Additions
    - New assault rifle: ACR-W added to the Season 2 Battle Pass (free track, tier 15).
    - New LMG: Nemesis 7 available from the weapons bench at rank 25.
    - New gadget: Deployable Sonar — a small device that pings nearby enemies through walls every 8 seconds.

    Balance Changes
    - Assault class: Repair Tool heal rate reduced by 10% to lower self-sustain in close quarters.
    - Attack helicopters: Flare cooldown increased from 18s to 22s.
    - C5 explosive: Detach range reduced from 15m to 12m.
    - MTAR-21: Recoil increased to reduce close-range dominance.

    Conquest Scoring
    - Ticket bleed rate increased by 10% when holding 3 or more flags — rewards aggressive flag capture.

    Bug Fixes
    - Fixed a collision issue on North Sea Platform where players could fall through a gantry walkway.
    - Resolved attack helicopter minigun audio cutting out after sustained fire.
    - Fixed Conquest ticket count occasionally desyncing between team HUDs.
  TEXT
  summaries: {
    "quick_summary" => "Season 2 drops with the North Sea Platform — a vertical oil rig map that is one of the most unique Battlefield environments in recent memory. A new Apache helicopter and a Recon specialist with sonar abilities add new tactical layers. The C5 nerf and reduced Assault self-heal should make close-quarters fights feel less frustrating to play against.",
    "casual_impact" => "North Sea Platform rewards players who understand vertical positioning and flanking routes — worth a few practice runs in casual modes first. The new ACR-W rifle is free on the Battle Pass and performs well straight away without heavy attachments. Conquest now rewards capturing flags faster which suits aggressive playstyles.",
    "should_i_log_in" => "Yes — Season 2 is a substantial content drop with a new map, specialist, vehicle, and weapons all at once. North Sea Platform alone is worth coming back for, and the free Battle Pass track means you earn new gear just by playing normally."
  }
)

puts "Creating events..."

seed_event_series(
  game: fortnite,
  events: [
    { title: "FNCS Major 1 Online Opens", description: "The opening stretch of FNCS Major 1 begins, with online competition deciding who advances deeper into the split.", start_date: DateTime.new(2026, 4, 6, 18, 0, 0) },
    { title: "FNCS Major 1 Finals Weekend", description: "Top Fortnite squads battle through the closing Major 1 finals weekend for qualification, points, and prize money.", start_date: DateTime.new(2026, 4, 25, 19, 0, 0) },
    { title: "FNCS Major 1 Summit", description: "The in-person Major 1 Summit lands in Dusseldorf with the season's top teams competing on stage.", start_date: DateTime.new(2026, 5, 30, 12, 0, 0) }
  ]
)

seed_event_series(
  game: warzone,
  events: [
    { title: "Season 02 Reloaded Launch", description: "The Season 02 Reloaded update deploys with playlist refreshes, event content, and mid-season balance changes.", start_date: DateTime.new(2026, 3, 11, 17, 0, 0) },
    { title: "Black Ops Royale Launch", description: "The new Black Ops Royale experience goes live in Warzone with mode-specific mechanics and rewards.", start_date: DateTime.new(2026, 3, 13, 17, 0, 0) },
    { title: "Altitude Tactics Event", description: "A limited-time Warzone event built around Season 02 Reloaded, with themed objectives and unlocks.", start_date: DateTime.new(2026, 3, 13, 19, 0, 0) }
  ]
)

seed_event_series(
  game: apex,
  events: [
    { title: "ALGS Online Open #4", description: "The fourth ALGS Online Open of Year 6 gives aspiring squads one of the earliest big competitive proving grounds of the season.", start_date: DateTime.new(2026, 3, 21, 16, 0, 0) },
    { title: "ALGS Pro League Split 1 Opening Weekend", description: "Pro League Split 1 begins, kicking off the first major block of ALGS league play for Year 6.", start_date: DateTime.new(2026, 4, 5, 16, 0, 0) },
    { title: "ALGS Challenger Circuit Split 1 #4", description: "The Challenger Circuit continues with another official Year 6 event for rising teams looking to break through.", start_date: DateTime.new(2026, 6, 6, 16, 0, 0) }
  ]
)

seed_event_series(
  game: destiny,
  events: [
    { title: "Guardian Games Cup", description: "A spring competition event spotlighting class pride, medals, and limited-time Guardian Games progression.", start_date: DateTime.new(2026, 3, 24, 17, 0, 0) },
    { title: "Iron Banner Week 1", description: "Lord Saladin returns for the first confirmed Iron Banner window of the spring, bringing boosted rep and featured loot.", start_date: DateTime.new(2026, 4, 1, 17, 0, 0) },
    { title: "Iron Banner Week 2", description: "The second confirmed Iron Banner week arrives later in the season with another chance at pinnacles and focused rewards.", start_date: DateTime.new(2026, 4, 29, 17, 0, 0) }
  ]
)

seed_event_series(
  game: fifa,
  events: [
    { title: "Team of the Season Warm-Up", description: "The annual Team of the Season ramp-up begins with early SBCs, objectives, and FUT engagement rewards.", start_date: DateTime.new(2026, 4, 24, 18, 0, 0) },
    { title: "Premier League Team of the Season", description: "One of the headline TOTS squad drops arrives, putting top Premier League cards into packs and objectives.", start_date: DateTime.new(2026, 5, 8, 18, 0, 0) },
    { title: "Ultimate TOTS Weekend", description: "Ultimate Team's marquee late-cycle TOTS weekend brings a stacked squad, upgraded SBCs, and high-end rewards.", start_date: DateTime.new(2026, 6, 5, 18, 0, 0) }
  ]
)

seed_event_series(
  game: roblox,
  events: [
    { title: "Arun Games Fest 2026", description: "A real featured Roblox event spotlighting curated experiences and creator-led sessions across the platform.", start_date: DateTime.new(2026, 3, 14, 16, 0, 0) },
    { title: "Creator Spotlight: AlewComeBack", description: "A scheduled Roblox creator spotlight event showcasing a featured builder and their community work.", start_date: DateTime.new(2026, 3, 20, 17, 0, 0) },
    { title: "Introduction to TeleportService Quickfire", description: "A Roblox learning event focused on TeleportService basics for creators building connected experiences.", start_date: DateTime.new(2026, 3, 27, 17, 0, 0) }
  ]
)

seed_event_series(
  game: clash,
  events: [
    { title: "March Update 2026", description: "The official March Clash Royale update lands with seasonal changes, new progression beats, and balance adjustments.", start_date: DateTime.new(2026, 3, 2, 9, 0, 0) },
    { title: "Choose Your Heroes Rollout", description: "The spring rollout of the Choose Your Heroes feature adds a fresh event beat for deck-building and engagement.", start_date: DateTime.new(2026, 3, 15, 10, 0, 0) },
    { title: "Global Tournaments Return", description: "Global Tournaments come back later in March, giving competitive players another official ladder-style event window.", start_date: DateTime.new(2026, 3, 27, 10, 0, 0) }
  ]
)

seed_event_series(
  game: coc,
  events: [
    { title: "Dragon Escape Season", description: "The March season begins in Clash of Clans with a themed pass, seasonal challenges, and fresh cosmetic rewards.", start_date: DateTime.new(2026, 3, 1, 8, 0, 0) },
    { title: "Dragon Duke Unleashed", description: "A featured seasonal event tied to the Dragon Duke theme goes live with themed progression and rewards.", start_date: DateTime.new(2026, 3, 1, 9, 0, 0) },
    { title: "Clan Games and Super Troop Discounts", description: "Late-month Clan Games return alongside Super Troop discounts, making this one of the more active official event windows.", start_date: DateTime.new(2026, 3, 22, 8, 0, 0) }
  ]
)

seed_event_series(
  game: minecraft,
  events: [
    { title: "Minecraft Live Spring 2026", description: "Minecraft Live returns in the spring with announcements, previews, and community-focused reveals for the year ahead.", start_date: DateTime.new(2026, 3, 21, 17, 0, 0) },
    { title: "Chase the Skies Game Drop", description: "The Chase the Skies game drop rolls out as a major official content beat for Minecraft in mid-June.", start_date: DateTime.new(2026, 6, 17, 17, 0, 0) },
    { title: "Minecraft Live Fall 2026", description: "A second Minecraft Live-style event later in the year keeps the seed data feeling like a real ongoing Mojang calendar.", start_date: DateTime.new(2026, 9, 26, 17, 0, 0) }
  ]
)

seed_event_series(
  game: valorant,
  events: [
    { title: "VCT Stage 1 Begins", description: "The 2026 VCT calendar opens Stage 1 play, setting the tone for the next international qualification cycle.", start_date: DateTime.new(2026, 4, 1, 18, 0, 0) },
    { title: "VCT Masters London", description: "Masters London arrives as one of Valorant's headline international LAN events of the 2026 season.", start_date: DateTime.new(2026, 6, 6, 12, 0, 0) },
    { title: "VCT Stage 2 Begins", description: "The second VCT stage starts at the end of June, resetting the focus toward the back half of the season.", start_date: DateTime.new(2026, 6, 30, 18, 0, 0) }
  ]
)

seed_event_series(
  game: marvel,
  events: [
    { title: "Season 2 Launch Window", description: "A realistic live-service season launch beat for Marvel Rivals with balance changes, battle pass content, and featured missions.", start_date: DateTime.new(2026, 4, 12, 18, 0, 0) },
    { title: "Midtown Mayhem Playlist Event", description: "A themed featured playlist event centered on Midtown, daily objectives, and team-up bonus rewards.", start_date: DateTime.new(2026, 5, 19, 19, 0, 0) },
    { title: "New Hero Spotlight Week", description: "A hero release week-style event that fits the cadence of a modern hero shooter, with missions and cosmetic unlocks.", start_date: DateTime.new(2026, 6, 25, 18, 0, 0) }
  ]
)

seed_event_series(
  game: helldivers,
  events: [
    { title: "Major Order: Frontline Push", description: "A community-wide push to reclaim contested worlds with bonus medals for all successful divers.", start_date: DateTime.new(2026, 3, 23, 17, 0, 0) },
    { title: "Weapons Proving Week", description: "New stratagem modifiers and daily operations encourage squads to test alternate loadouts.", start_date: DateTime.new(2026, 5, 11, 18, 0, 0) },
    { title: "Galaxy Defense Broadcast", description: "Super Earth command issues a live update on the war effort and unlocks a fresh operation set.", start_date: DateTime.new(2026, 6, 30, 19, 0, 0) }
  ]
)

seed_event_series(
  game: overwatch2,
  events: [
    { title: "Season 16 Battle Pass Launch", description: "Season 16 goes live with a new Battle Pass, Freja hero unlock, and the Esperança map added to all rotations.", start_date: DateTime.new(2026, 4, 8, 18, 0, 0) },
    { title: "Overwatch World Cup Qualifiers", description: "National teams begin their qualifying runs for the Overwatch World Cup with online open stages across all regions.", start_date: DateTime.new(2026, 5, 3, 17, 0, 0) },
    { title: "Anniversary Remix Event", description: "The annual Anniversary event returns with a rotating arcade, returning cosmetics, and limited-time challenges.", start_date: DateTime.new(2026, 5, 20, 18, 0, 0) }
  ]
)

seed_event_series(
  game: re_requiem,
  events: [
    { title: "Mercenaries Mode Launch", description: "The post-launch Mercenaries mode goes live, adding a score-attack survival mode with ranked leaderboards.", start_date: DateTime.new(2026, 4, 17, 17, 0, 0) },
    { title: "Resident Evil Day Community Event", description: "An annual community celebration with in-game unlocks, developer streams, and fan showcase highlights.", start_date: DateTime.new(2026, 5, 21, 17, 0, 0) },
    { title: "Requiem New Game+ Challenge", description: "A timed leaderboard event for New Game+ runs with developer-verified times and exclusive cosmetic rewards.", start_date: DateTime.new(2026, 6, 14, 18, 0, 0) }
  ]
)

seed_event_series(
  game: pokemon_pokopia,
  events: [
    { title: "Festival of Seasons: Spring", description: "The Spring phase of the Festival of Seasons kicks off with Cherry Blossom-themed encounters and exclusive Pokémon spawns.", start_date: DateTime.new(2026, 3, 20, 10, 0, 0) },
    { title: "Pokopia Regional Championship", description: "The first official in-game ranked tournament season opens with tiered rewards for competitive trainers.", start_date: DateTime.new(2026, 4, 25, 14, 0, 0) },
    { title: "Legendary Raid Weekend", description: "A limited-time raid weekend featuring rare Legendary encounters in the Crystalline Caverns with boosted catch rates.", start_date: DateTime.new(2026, 5, 30, 10, 0, 0) }
  ]
)

seed_event_series(
  game: battlefront2,
  events: [
    { title: "Scarif Community Event", description: "A limited-time community challenge on the new Scarif map with bonus XP and milestone rewards for participation.", start_date: DateTime.new(2026, 3, 28, 18, 0, 0) },
    { title: "Rogue One Heroes Weekend", description: "A featured playlist spotlighting Jyn Erso and Director Krennic with double hero token earnings.", start_date: DateTime.new(2026, 4, 18, 18, 0, 0) },
    { title: "Galactic Assault Championship", description: "A community-organised tournament series across Galactic Assault maps with seasonal leaderboard tracking.", start_date: DateTime.new(2026, 6, 14, 17, 0, 0) }
  ]
)

seed_event_series(
  game: horizon_fw,
  events: [
    { title: "Burning Shores Launch Weekend", description: "The Burning Shores DLC launches with a free trial period for the new Scarlet Shore outpost and community showcase streams.", start_date: DateTime.new(2026, 4, 5, 17, 0, 0) },
    { title: "Machine Strike Tournament", description: "An official Machine Strike challenge event with ranked matches and exclusive cosmetic rewards for top players.", start_date: DateTime.new(2026, 5, 9, 18, 0, 0) },
    { title: "Cauldron Speed Run Challenge", description: "A community speed run event across all Cauldrons, with developer-verified times and a special trophy for completionists.", start_date: DateTime.new(2026, 7, 11, 17, 0, 0) }
  ]
)

seed_event_series(
  game: ff7_rebirth,
  events: [
    { title: "Queen's Blood World Championship", description: "The first official Queen's Blood card game tournament with online qualifiers and a grand finals broadcast.", start_date: DateTime.new(2026, 4, 12, 14, 0, 0) },
    { title: "Chadley's Combat Simulator Challenge", description: "A limited-time battle simulator event with new encounter configurations and exclusive accessory rewards.", start_date: DateTime.new(2026, 5, 24, 17, 0, 0) },
    { title: "Piano Performance Showcase", description: "A community event spotlighting the in-game piano minigame with fan submissions and developer-curated highlights.", start_date: DateTime.new(2026, 6, 28, 18, 0, 0) }
  ]
)

seed_event_series(
  game: spiderman2,
  events: [
    { title: "New Game+ Launch Week", description: "The New Game+ mode goes live with a community celebration week featuring developer streams and challenge milestones.", start_date: DateTime.new(2026, 3, 22, 17, 0, 0) },
    { title: "Photo Mode Community Contest", description: "An official photo mode contest where players submit their best shots of Manhattan for featured prizes.", start_date: DateTime.new(2026, 4, 26, 18, 0, 0) },
    { title: "Ultimate Difficulty Leaderboard Event", description: "A timed Ultimate difficulty challenge where top players compete for placement on a global leaderboard.", start_date: DateTime.new(2026, 6, 7, 17, 0, 0) }
  ]
)

seed_event_series(
  game: gta_online,
  events: [
    { title: "Bottom Dollar Bounties Week", description: "Double GTA$ and RP on all Bottom Dollar Bounties contracts for the week, plus exclusive clothing unlocks.", start_date: DateTime.new(2026, 3, 27, 9, 0, 0) },
    { title: "HSW Time Trials", description: "Weekly HSW Time Trials go live across Los Santos and Blaine County with top-tier vehicle payouts.", start_date: DateTime.new(2026, 4, 17, 9, 0, 0) },
    { title: "GTA Online Anniversary Event", description: "An annual celebration with returning limited-time modes, bonus payouts across all businesses, and exclusive cosmetics.", start_date: DateTime.new(2026, 10, 1, 9, 0, 0) }
  ]
)

seed_event_series(
  game: lol,
  events: [
    { title: "Split 3 Ranked Season Start", description: "Split 3 begins with Patch 14.12 — all players receive LP adjustments and the new ranked icons go live.", start_date: DateTime.new(2026, 4, 2, 10, 0, 0) },
    { title: "MSI 2026", description: "The Mid-Season Invitational brings together the top teams from every major region to compete for global glory.", start_date: DateTime.new(2026, 5, 1, 12, 0, 0) },
    { title: "World Championship 2026", description: "The pinnacle of the competitive season — the World Championship crowns the best team in League of Legends.", start_date: DateTime.new(2026, 10, 3, 12, 0, 0) }
  ]
)

seed_event_series(
  game: cyberpunk,
  events: [
    { title: "Night City Wire: Phantom Retrospective", description: "A developer broadcast looking back at Phantom Liberty and teasing upcoming content updates for 2026.", start_date: DateTime.new(2026, 4, 10, 18, 0, 0) },
    { title: "New Gig Drop: The Afterimage", description: "The new Dogtown multi-stage contract goes live alongside a limited-time community challenge with unique rewards.", start_date: DateTime.new(2026, 4, 17, 17, 0, 0) },
    { title: "Edgerunner Community Day", description: "A community celebration with fan art showcases, speed run competitions, and developer Q&A streams.", start_date: DateTime.new(2026, 6, 21, 17, 0, 0) }
  ]
)

seed_event_series(
  game: space_marine2,
  events: [
    { title: "Eternal War Season 1 Launch", description: "PvP Eternal War Season 1 begins with the new maps, Dark Angels chapter, and inaugural ranked leaderboards.", start_date: DateTime.new(2026, 3, 28, 17, 0, 0) },
    { title: "The Reclamation Co-Op Event", description: "A featured week for the new Reclamation Operations mission with double requisition rewards and challenge milestones.", start_date: DateTime.new(2026, 4, 23, 17, 0, 0) },
    { title: "Warhammer Skulls Festival", description: "The annual Warhammer digital festival brings a discount week, exclusive cosmetics, and a community challenge across Operations.", start_date: DateTime.new(2026, 6, 4, 17, 0, 0) }
  ]
)

seed_event_series(
  game: twoxko,
  events: [
    { title: "Season 1 Ranked Launch", description: "The first competitive season of 2XKO goes live alongside Illaoi and Ambessa — placement matches determine your starting rank.", start_date: DateTime.new(2026, 3, 26, 18, 0, 0) },
    { title: "2XKO Open Invitational", description: "The first official 2XKO tournament invites top-ranked players for a streamed event with prize money and exclusive cosmetics.", start_date: DateTime.new(2026, 5, 16, 17, 0, 0) },
    { title: "New Champion Reveal Event", description: "A live community event unveiling the next champion to join the roster, with early access trials for ranked players.", start_date: DateTime.new(2026, 7, 9, 18, 0, 0) }
  ]
)

seed_event_series(
  game: genshin,
  events: [
    { title: "Lantern Rite Festival", description: "The annual Liyue lantern festival returns with story quests, free 4-star character selector, and limited-time minigames.", start_date: DateTime.new(2026, 4, 4, 10, 0, 0) },
    { title: "Summertime Odyssey", description: "A summer event chain set on a newly accessible island with exclusive cosmetics and a free 4-star character reward.", start_date: DateTime.new(2026, 7, 7, 10, 0, 0) },
    { title: "Version 5.6 Preview Livestream", description: "The official developer livestream reveals the next version's characters, events, and redeem codes live.", start_date: DateTime.new(2026, 5, 23, 12, 0, 0) }
  ]
)

seed_event_series(
  game: cs2,
  events: [
    { title: "CS2 Major: Copenhagen 2026", description: "One of the year's two CS Majors lands in Copenhagen — the biggest tournament in the Counter-Strike calendar.", start_date: DateTime.new(2026, 5, 4, 13, 0, 0) },
    { title: "Operation Launch", description: "A new CS2 Operation goes live with a mission pass, new case, and community-created maps added to casual and deathmatch.", start_date: DateTime.new(2026, 4, 14, 17, 0, 0) },
    { title: "Train Map Return Event", description: "A featured week celebrating Train's return to Active Duty with community challenges and limited sprays.", start_date: DateTime.new(2026, 3, 25, 17, 0, 0) }
  ]
)

seed_event_series(
  game: dota2,
  events: [
    { title: "The International 2026 Qualifiers", description: "Regional qualifiers begin to determine which teams earn direct invitations to The International.", start_date: DateTime.new(2026, 7, 1, 14, 0, 0) },
    { title: "Diretide Event", description: "The annual Halloween event returns with Roshan candy mechanics, themed cosmetics, and a limited-time game mode.", start_date: DateTime.new(2026, 10, 15, 17, 0, 0) },
    { title: "Battle Pass 2026 Launch", description: "The annual Battle Pass goes live with a new Arcana vote, exclusive cosmetics, and community milestones.", start_date: DateTime.new(2026, 5, 12, 17, 0, 0) }
  ]
)

seed_event_series(
  game: baldurs_gate3,
  events: [
    { title: "Patch 8 Community Celebration", description: "A community event marking the Patch 8 launch with developer streams, fan art showcases, and lore discussions.", start_date: DateTime.new(2026, 3, 28, 18, 0, 0) },
    { title: "Honour Mode World Record Sprint", description: "A community speed run challenge for Honour Mode completions — fastest verified times earn featured recognition.", start_date: DateTime.new(2026, 5, 2, 17, 0, 0) },
    { title: "BG3 Anniversary Celebration", description: "The third anniversary of the full release is marked with developer retrospectives, community highlights, and in-game surprises.", start_date: DateTime.new(2026, 8, 3, 17, 0, 0) }
  ]
)

seed_event_series(
  game: pubg,
  events: [
    { title: "Rondo Launch Week", description: "Rondo goes live with a featured playlist, double BP earnings on the new map, and early-access community challenges.", start_date: DateTime.new(2026, 4, 1, 10, 0, 0) },
    { title: "PUBG Global Championship 2026 — Qualifiers", description: "Regional qualifiers begin for the PGC 2026, the largest prize pool event on the PUBG esports calendar.", start_date: DateTime.new(2026, 7, 15, 14, 0, 0) },
    { title: "Ranked Season 32 End & Rewards", description: "Season 32 draws to a close — final rank distributions are locked and cosmetic rewards are distributed to all eligible players.", start_date: DateTime.new(2026, 6, 30, 10, 0, 0) }
  ]
)

seed_event_series(
  game: battlefield6,
  events: [
    { title: "Steel Horizon Season 2 Launch", description: "Season 2 goes live with North Sea Platform, the Apache helicopter, and a new specialist available from day one.", start_date: DateTime.new(2026, 4, 8, 17, 0, 0) },
    { title: "Battlefield Portal Week", description: "A featured Battlefield Portal event brings back classic maps and weapons from previous titles with double XP.", start_date: DateTime.new(2026, 5, 7, 17, 0, 0) },
    { title: "Community Conquest Challenge", description: "A time-limited Conquest event with global team targets — players contribute to a shared win counter for milestone rewards.", start_date: DateTime.new(2026, 6, 18, 17, 0, 0) }
  ]
)

puts "Seeds finished!"
