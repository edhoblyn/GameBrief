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

def seed_live_events(game:, importer_class:)
  return unless game

  result = importer_class.new.call(replace: true)
  if result.imported > 0
    puts "Imported #{result.imported} live events for #{game.name} (#{result.skipped} already existed)."
  else
    puts "No live events found for #{game.name} — seeded events were not changed."
  end
rescue StandardError => e
  puts "Skipping live event import for #{game&.name}: #{e.class}: #{e.message}"
end

def seed_live_patches(source)
  config = PatchScrapeRunner.fetch(source)
  return unless PatchScrapeRunner.scrapeable?(source)

  result = PatchScrapeRunner.run(source)
  puts "Imported live patches for #{config[:label]}: #{result.imported} imported, #{result.skipped} skipped."
  result
rescue StandardError => e
  puts "Skipping live patch import for #{source}: #{e.class}: #{e.message}"
  nil
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
Game.where(name: "2XKO").destroy_all
Game.where(name: "Overwatch 2: Invasion Bundle").update_all(name: "Overwatch 2")
Game.where(name: "Genshin Impact: Blades Weaving Betwixt Brocade").update_all(name: "Genshin Impact")

puts "Importing games from IGDB..."

client = IgdbClient.new

def import_game(client, query, name: nil, slug: nil, free_to_play: false, single_player: false, multiplayer: false)
  results = client.search_games(query)
  match = results.find { |g| g["name"]&.downcase == query.downcase && g["cover"] }
  match ||= results.find { |g| g["cover"] }
  match ||= results.first
  return nil unless match

  cover_url = match["cover"] ? "https:#{match["cover"]["url"].gsub("t_thumb", "t_cover_big")}" : nil
  resolved_slug = slug || match["slug"]

  game = Game.where("LOWER(name) = ?", query.downcase).first
  game ||= Game.find_by(slug: resolved_slug) if resolved_slug.present?
  game ||= Game.find_by(slug: match["slug"]) if match["slug"].present?
  game ||= Game.new

  game.update!(
    name: name || match["name"],
    slug: resolved_slug,
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
overwatch2    = import_game(client, "Overwatch 2", name: "Overwatch 2", free_to_play: true, multiplayer: true)
re_requiem    = import_game(client, "Resident Evil Requiem", free_to_play: false, single_player: true)
pokemon_pokopia = import_game(client, "Pokémon Pokopia", free_to_play: false, single_player: true)
battlefront2  = import_game(client, "Star Wars Battlefront II", free_to_play: false, single_player: true, multiplayer: true)
horizon_fw    = import_game(client, "Horizon Forbidden West", free_to_play: false, single_player: true)
ff7_rebirth   = import_game(client, "Final Fantasy VII Rebirth", free_to_play: false, single_player: true)
spiderman2    = import_game(client, "Marvel's Spider-Man 2", free_to_play: false, single_player: true)
gta_online    = import_game(client, "Grand Theft Auto V", name: "GTA 5: Online", slug: "gta-5-online", free_to_play: false, single_player: false, multiplayer: true)
lol           = import_game(client, "League of Legends", free_to_play: true, multiplayer: true)
cyberpunk     = import_game(client, "Cyberpunk 2077", free_to_play: false, single_player: true)
space_marine2 = import_game(client, "Warhammer 40,000: Space Marine 2", free_to_play: false, single_player: true, multiplayer: true)
arc_raiders   = import_game(client, "ARC Raiders", free_to_play: false, multiplayer: true)
genshin       = import_game(client, "Genshin Impact", name: "Genshin Impact", slug: "genshin-impact", free_to_play: true, single_player: true, multiplayer: true)
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
  arc_raiders   => ["Shooter"],
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

seed_live_patches("battlefield_6")
seed_live_patches("baldurs_gate_3")
seed_live_patches("genshin_impact")
seed_live_patches("arc_raiders")
seed_live_patches("resident_evil_requiem")
seed_live_patches("league_of_legends")
seed_live_patches("counter_strike_2")
seed_live_patches("pubg_battlegrounds")
seed_live_patches("horizon_forbidden_west")
seed_live_patches("cyberpunk_2077")
seed_live_patches("space_marine_2")
seed_live_patches("spider_man_2")
seed_live_patches("gta_5_online")
seed_live_patches("dota_2")

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

seed_live_patches("pokemon_pokopia")
if pokemon_pokopia.present? && pokemon_pokopia.patches.where.not(source_url: nil).exists?
  pokemon_pokopia.patches.where(source_url: nil).find_each(&:destroy!)
end

seed_live_patches("star_wars_battlefront_ii")
seed_live_patches("ff7_rebirth")

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

puts "Creating events..."

fortnite&.events&.destroy_all
seed_event_series(
  game: fortnite,
  events: [
    {
      title: "Fortnite — New Season Launch",
      description: "A new Fortnite season begins — bringing a fresh Battle Pass with new skins to unlock, map changes, new weapons, and a seasonal story to follow across the chapter.",
      start_date: DateTime.new(2026, 6, 5, 18, 0, 0)
    },
    {
      title: "Fortnitemares 2026",
      description: "Fortnitemares returns for Halloween — Fortnite's annual spooky season with themed limited-time modes, free horror-inspired cosmetics, and a Halloween-themed Battle Royale map makeover.",
      start_date: DateTime.new(2026, 10, 15, 18, 0, 0)
    },
    {
      title: "Fortnite Winterfest 2026",
      description: "Winterfest returns — Fortnite's annual winter celebration with 14 days of free gifts, festive cosmetics, the Cozy Lodge to visit daily, and limited-time holiday modes.",
      start_date: DateTime.new(2026, 12, 17, 18, 0, 0)
    }
  ]
)

warzone&.events&.destroy_all
seed_event_series(
  game: warzone,
  events: [
    {
      title: "Call of Duty: Warzone Season 03",
      description: "Season 03 launches with major map changes, new weapons, fresh operators, and a brand-new Battle Pass with exclusive cosmetics across 100 tiers.",
      start_date: DateTime.new(2026, 4, 30, 17, 0, 0)
    },
    {
      title: "Call of Duty: Warzone Season 03 Reloaded",
      description: "The Season 03 Reloaded mid-season drop arrives with new limited-time modes, operator bundles, bonus Battle Pass content, and in-game event challenges.",
      start_date: DateTime.new(2026, 6, 11, 17, 0, 0)
    }
  ]
)

seed_live_events(game: apex, importer_class: EventImporters::ApexLegendsEventImporter)

destiny&.events&.destroy_all
seed_event_series(
  game: destiny,
  events: [
    {
      title: "Destiny 2 — Guardian Games 2026",
      description: "Guardian Games returns — Titans, Hunters, and Warlocks compete for class supremacy with daily Medallions, a community Podium event, and exclusive class-themed cosmetics to earn.",
      start_date: DateTime.new(2026, 4, 21, 17, 0, 0)
    },
    {
      title: "Destiny 2 — Next Episode Launch",
      description: "The next major Destiny 2 Episode arrives after Renegades — bringing a new story campaign, seasonal activities, exotic weapons to chase, and a fresh artifact mod to unlock. Launch confirmed for June 2026.",
      start_date: DateTime.new(2026, 6, 9, 17, 0, 0)
    },
    {
      title: "Destiny 2 — Solstice 2026",
      description: "Solstice of Heroes returns for summer — the annual event with an armour-glow upgrade system, limited-time activities, and exclusive cosmetics to earn before the season ends.",
      start_date: DateTime.new(2026, 8, 4, 17, 0, 0)
    }
  ]
)

seed_live_events(game: fifa, importer_class: EventImporters::EaSportsFc26EventImporter)
seed_event_series(
  game: fifa,
  events: [
    {
      title: "EA SPORTS FC 26 — Team of the Season",
      description: "Team of the Season arrives — the best-performing players from top leagues around the world receive their highest-rated FUT cards of the year, available through packs, SBCs, and objectives.",
      start_date: DateTime.new(2026, 5, 8, 18, 0, 0)
    }
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

clash&.events&.destroy_all
seed_event_series(
  game: clash,
  events: [
    {
      title: "Clash Royale April Season",
      description: "A new Clash Royale season begins — the Pass Royale resets with a fresh theme and exclusive tower skins, emotes, and cosmetics, plus new cards to unlock and upgrade.",
      start_date: DateTime.new(2026, 4, 1, 8, 0, 0)
    },
    {
      title: "Clash Royale — Global Tournament April 2026",
      description: "Global Tournaments are open — enter with a limited-use deck and compete for trophies, Gold, and exclusive in-game rewards on the global leaderboard.",
      start_date: DateTime.new(2026, 4, 10, 8, 0, 0)
    },
    {
      title: "Clash Royale May Season",
      description: "May's new season arrives in Clash Royale — bringing a fresh Pass Royale, updated shop cosmetics, new card releases, and mid-season content drops.",
      start_date: DateTime.new(2026, 5, 1, 8, 0, 0)
    }
  ]
)

coc&.events&.destroy_all
seed_event_series(
  game: coc,
  events: [
    {
      title: "Clash of Clans — Clan Games March 2026",
      description: "Clan Games are back — complete individual challenges to earn points for your Clan and unlock tiered rewards including Magic Items, Book of Heroes, and cosmetics.",
      start_date: DateTime.new(2026, 3, 22, 8, 0, 0)
    },
    {
      title: "Clash of Clans April Season",
      description: "A new Clash of Clans season begins — the April Gold Pass launches with a fresh themed skin, season challenges, and exclusive cosmetic rewards for Gold Pass holders.",
      start_date: DateTime.new(2026, 4, 1, 8, 0, 0)
    },
    {
      title: "Clash of Clans — Clan Games April 2026",
      description: "Clan Games return for April — team up with your Clan to complete challenges and earn Magic Items, Book of Building, and other progression rewards.",
      start_date: DateTime.new(2026, 4, 22, 8, 0, 0)
    }
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

seed_live_events(game: valorant, importer_class: EventImporters::ValorantEventImporter)

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

ff7_rebirth&.events&.destroy_all
seed_event_series(
  game: ff7_rebirth,
  events: [
    {
      title: "Final Fantasy VII — 30th Anniversary",
      description: "Final Fantasy VII celebrates its 30th anniversary — Square Enix typically marks major FF7 milestones with special announcements, retrospectives, and news about the ongoing Remake trilogy.",
      start_date: DateTime.new(2027, 1, 31, 12, 0, 0)
    }
  ]
)

seed_live_events(game: gta_online, importer_class: EventImporters::GtaOnlineEventImporter)

seed_event_series(
  game: lol,
  events: [
    { title: "Split 3 Ranked Season Start", description: "Split 3 begins with Patch 14.12 — all players receive LP adjustments and the new ranked icons go live.", start_date: DateTime.new(2026, 4, 2, 10, 0, 0) },
    { title: "MSI 2026", description: "The Mid-Season Invitational brings together the top teams from every major region to compete for global glory.", start_date: DateTime.new(2026, 5, 1, 12, 0, 0) },
    { title: "World Championship 2026", description: "The pinnacle of the competitive season — the World Championship crowns the best team in League of Legends.", start_date: DateTime.new(2026, 10, 3, 12, 0, 0) }
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

seed_live_events(game: arc_raiders, importer_class: EventImporters::ArcRaidersEventImporter)

seed_live_events(game: genshin, importer_class: EventImporters::GenshinImpactEventImporter)
seed_event_series(
  game: genshin,
  events: [
    {
      title: "Genshin Impact — Version Luna VI Launch",
      description: "The next Genshin Impact version arrives — bringing new story chapters, new playable characters with dedicated banners, in-game events, and fresh Primogems to earn through exploration and challenges.",
      start_date: DateTime.new(2026, 4, 8, 11, 0, 0)
    },
    {
      title: "Genshin Impact — Summer Archipelago Event",
      description: "The summer island event returns — a temporary Golden Apple Archipelago opens with story quests, a free 4-star character to claim, sailing mini-games, and exclusive cosmetic rewards.",
      start_date: DateTime.new(2026, 7, 8, 10, 0, 0)
    }
  ]
)

seed_live_events(game: cs2, importer_class: EventImporters::CounterStrike2EventImporter)

cyberpunk&.events&.destroy_all
seed_event_series(
  game: cyberpunk,
  events: [
    {
      title: "Cyberpunk 2077 — 6th Anniversary",
      description: "Cyberpunk 2077 marks its sixth anniversary — CD Projekt Red typically celebrates with a community retrospective, developer messages, and anniversary content highlighting the game's journey from launch to its final form.",
      start_date: DateTime.new(2026, 12, 10, 12, 0, 0)
    }
  ]
)

seed_live_events(game: dota2, importer_class: EventImporters::Dota2EventImporter)
seed_event_series(
  game: dota2,
  events: [
    {
      title: "Dota 2 Battle Pass 2026",
      description: "The annual Dota 2 Battle Pass launches — featuring a new Arcana cosmetic vote, hundreds of exclusive item rewards, community milestones, and a seasonal in-game event for all players.",
      start_date: DateTime.new(2026, 5, 19, 17, 0, 0)
    },
    {
      title: "Diretide 2026",
      description: "Diretide returns for Halloween — the annual event pitting players against Roshan in a candy-stealing game mode, with exclusive Diretide-themed cosmetics and item rewards.",
      start_date: DateTime.new(2026, 10, 15, 17, 0, 0)
    }
  ]
)

baldurs_gate3&.events&.destroy_all
seed_event_series(
  game: baldurs_gate3,
  events: [
    {
      title: "Path to Menzoberranzan — Community Mod Alpha",
      description: "A massive community-made campaign built by 130+ modders launches its first playable alpha. The prologue-sized release features a new protagonist, fully voiced companions, and an original story set in the Underdark city of Menzoberranzan.",
      start_date: DateTime.new(2026, 6, 1, 12, 0, 0)
    },
    {
      title: "Baldur's Gate 3 — 3rd Anniversary",
      description: "Baldur's Gate 3 turns three years old. Larian has historically marked anniversaries with community updates, retrospectives, and surprise gifts for players — a good excuse to start a new run or dust off a saved game.",
      start_date: DateTime.new(2026, 8, 3, 12, 0, 0)
    }
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

battlefield6&.events&.destroy_all
seed_event_series(
  game: battlefield6,
  events: [
    {
      title: "Battlefield 6 Season 2 Phase 3 — Hunter/Prey",
      description: "The third phase of Season 2 drops new limited-time modes, operator cosmetics, and in-game challenges. Hunter/Prey flips the formula with asymmetric objectives across existing maps.",
      start_date: DateTime.new(2026, 4, 12, 17, 0, 0)
    },
    {
      title: "Battlefield 6 Season 3",
      description: "Season 3 launches with a brand-new map, fresh operators, a new Battle Pass with exclusive cosmetics, and a ranked reset — the biggest content drop since launch.",
      start_date: DateTime.new(2026, 5, 15, 17, 0, 0)
    }
  ]
)

puts "Seeds finished!"
