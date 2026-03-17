# GameBrief - Scraping Guide

## Purpose

Document how patch-note scraping works in GameBrief, which sources are supported, how imports are run, and what source-specific issues currently exist.

## Scope

This guide covers patch-note scraping only.

Game metadata import from IGDB is documented separately in:
[4GameBrief_IGDB_Integration_Guide.md](/Users/edhoblyn/GameBrief/Docs/Reference/4GameBrief_IGDB_Integration_Guide.md)

## Architecture

GameBrief uses three layers for patch ingestion:

1. `Scrapers::*`
   Fetch and parse official patch-note or update pages.

2. `PatchImporters::*`
   Resolve the target `Game`, de-duplicate by `source_url`, and create or update `Patch` records.

3. `PatchScrapeRunner` / rake tasks
   Provide a shared execution path for manual imports, Heroku Scheduler, and future admin-triggered scrapes.

Flow:

Official source -> scraper -> importer -> `patches` table -> app UI

## Main Files

Scrapers live in:
`app/services/scrapers/`

Importers live in:
`app/services/patch_importers/`

Shared scrape runner lives in:
`app/services/patch_scrape_runner.rb`

Jobs live in:
`app/jobs/`

Manual tasks live in:
`lib/tasks/patches.rake`

Recurring schedule lives in:
`config/recurring.yml`

Future admin trigger endpoint lives in:
`app/controllers/admin/patch_scrapes_controller.rb`

## Patch Model Notes

The current scraper pipeline stores:

- `title`
- `content`
- `source_url`
- associated `game_id`

De-duplication is based on `source_url`.

The app does not currently store a dedicated `published_at` field for patches, so recency filtering depends on what each scraper can infer from the source page or source index.

## Supported Games

The following games currently have scraper support in the repo:

**Scrapeable (automated):**

- ARC Raiders
- Apex Legends
- Baldur's Gate 3
- Battlefield 6
- Call of Duty: Warzone
- Clash of Clans
- Clash Royale
- Counter-Strike 2
- Cyberpunk 2077
- Dota 2
- EA Sports FC 26
- Final Fantasy VII Rebirth
- Genshin Impact
- Horizon Forbidden West: Complete Edition
- League of Legends
- Marvel Rivals
- Marvel's Spider-Man 2
- Overwatch 2
- PUBG: Battlegrounds
- Pokémon Pokopia
- Resident Evil Requiem
- Roblox
- Star Wars Battlefront II
- Valorant
- Warhammer 40,000: Space Marine 2

**Blocked / requires alternate ingestion:**

- Destiny 2 (JS-driven, no reliable scrape endpoint)
- Fortnite (Cloudflare bot protection)
- GTA 5: Online (curated manual data — Rockstar pages are not reliably scrapeable)
- Helldivers 2 (Cloudflare bot protection)
- Minecraft (Cloudflare bot protection)

## Current Source Strategy

### EA / official news pages

Used for:

- Apex Legends
- Battlefield 6
- EA Sports FC 26
- Star Wars Battlefront II

Pattern:

- scrape official EA news index
- filter links by category tag or title pattern
- fetch article page
- extract title and main content

### Steam News API (JSON events)

Used for:

- Baldur's Gate 3
- Counter-Strike 2
- Cyberpunk 2077
- Dota 2
- Final Fantasy VII Rebirth
- Horizon Forbidden West: Complete Edition
- Marvel's Spider-Man 2

Pattern:

- fetch `https://store.steampowered.com/news/app/<APP_ID>?updates=true`
- parse JSON event entries from the response
- filter by `event_type` and title pattern
- build `source_url` from the Steam news detail URL template

### Supercell archives

Used for:

- Clash Royale
- Clash of Clans

Pattern:

- scrape the current `/blog/` archive page
- read article metadata from `__NEXT_DATA__`
- limit to the last 6 months using source publish dates
- fetch matching article pages

Important:

Supercell moved away from the old `/blog/release-notes/` archive URLs. The active archive pages are:

- `https://supercell.com/en/games/clashroyale/blog/`
- `https://supercell.com/en/games/clashofclans/blog/`

### Structured release-note payloads

Used for:

- Roblox

Pattern:

- parse `__NEXT_DATA__` from Roblox Creator Hub release-note pages
- walk the `next` / `prev` release-note chain
- build patch content from structured release-note entries

### HoyoLab API

Used for:

- Genshin Impact

Pattern:

- call the HoyoLab community post API (`bbs-api-os.hoyolab.com`) with `curl` to bypass browser fingerprinting
- filter by official user ID and news type
- fetch full post content via the detail API endpoint
- limit to the last 6 months

### Generic HTML extraction

Used for:

- ARC Raiders (tag-filtered news index at arcraiders.com)
- League of Legends (patch-notes tag index at leagueoflegends.com)
- Marvel Rivals
- Overwatch 2 (paginated patch-notes page at ga.overwatch.blizzard.com)
- PUBG: Battlegrounds (paginated news index with inline JSON at pubg.com)
- Valorant
- Warzone

Pattern:

- fetch index page
- collect matching links (by title pattern or category tag)
- fetch article page
- extract content from `main`, `article`, or similar container

### Steam Community announcements

Used for:

- Resident Evil Requiem

Pattern:

- fetch the game's Steam Community announcements page (`steamcommunity.com/app/<APP_ID>/announcements/`)
- filter announcement cards by title keyword pattern
- extract title and body content from each card

### Focus Entertainment community blog (curl-based)

Used for:

- Warhammer 40,000: Space Marine 2

Pattern:

- fetch the Focus Entertainment community blog index with `curl` to bypass browser fingerprinting
- filter posts by title pattern (patch notes, hotfix, update is live)
- limit to the last 6 months
- extract structured content from matching blog posts

### Multi-source aggregation

Used for:

- Pokémon Pokopia

Pattern:

- fetch from multiple official sources (Pokémon press site, Nintendo news, Pokopia microsite)
- each source has a dedicated parser
- results are combined and de-duplicated by source URL

### Curated manual data

Used for:

- GTA 5: Online

Pattern:

- patch content is curated from official Rockstar Support notes and seeded directly
- automated scraping is disabled because Rockstar's public update pages are not reliably scrapeable

## Manual Commands

Full list of available rake tasks:

```bash
bin/rake patches:scrape_arc_raiders
bin/rake patches:scrape_apex_legends
bin/rake patches:scrape_baldurs_gate_3
bin/rake patches:scrape_battlefield_6
bin/rake patches:scrape_clash_of_clans
bin/rake patches:scrape_clash_royale
bin/rake patches:scrape_counter_strike_2
bin/rake patches:scrape_cyberpunk_2077
bin/rake patches:scrape_dota_2
bin/rake patches:scrape_ea_sports_fc_26
bin/rake patches:scrape_ff7_rebirth
bin/rake patches:scrape_genshin_impact
bin/rake patches:scrape_horizon_forbidden_west
bin/rake patches:scrape_league_of_legends
bin/rake patches:scrape_marvel_rivals
bin/rake patches:scrape_overwatch_2
bin/rake patches:scrape_pokemon_pokopia
bin/rake patches:scrape_pubg_battlegrounds
bin/rake patches:scrape_resident_evil_requiem
bin/rake patches:scrape_roblox
bin/rake patches:scrape_space_marine_2
bin/rake patches:scrape_spider_man_2
bin/rake patches:scrape_star_wars_battlefront_ii
bin/rake patches:scrape_valorant
bin/rake patches:scrape_warzone
```

Disabled sources (skip automatically in `scrape_all`, can still be called manually but will print a skip message):

```bash
bin/rake patches:scrape_destiny_2
bin/rake patches:scrape_fortnite
bin/rake patches:scrape_gta_5_online
bin/rake patches:scrape_helldivers_2
bin/rake patches:scrape_minecraft
```

Run all scrapeable sources at once:

```bash
bin/rake patches:scrape_all
```

Heroku one-off import flow:

```bash
heroku run bin/rails db:migrate
heroku run bin/rails db:seed
heroku run bin/rake patches:scrape_all
```

## Scheduling

Recurring jobs are still defined in:
[config/recurring.yml](/Users/edhoblyn/GameBrief/config/recurring.yml)

However, on Heroku the production-safe scheduling path is:

1. Add the Heroku Scheduler add-on.
2. Create a scheduled job that runs:

```bash
bin/rake patches:scrape_all
```

Recommended cadence:

- daily for normal use
- hourly only if you need faster refreshes and are comfortable with more external requests

Why:

- the app currently does not boot a persistent in-app queue on Heroku
- `patches:scrape_all` is the simplest reliable production entrypoint
- it uses the same `PatchScrapeRunner` service as manual runs and future admin-triggered runs

The per-game `Scrape*Job` classes still exist in the repo, for example:

- `ScrapeWarzoneJob`
- `ScrapeApexLegendsJob`
- `ScrapeEaSportsFc26Job`

But they are not the primary production scheduling mechanism on Heroku right now.

## Future Admin Trigger

The app now has a shared backend path for manual admin-triggered scrapes.

Current endpoint:

- `POST /admin/patch_scrapes`

Expected param:

- `source`, for example `marvel_rivals`, `warzone`, or `fortnite`

Current access control:

- the controller checks `current_user.admin?`
- `User#admin?` is implemented defensively so it returns `false` until a real user `role` column and admin workflow are added

This means the backend path is ready, but no user can trigger it yet until admin roles are implemented.

## Recent Backfill Status

A live backfill was run to populate real patch data for supported games.

Games with real imported data now include:

- Apex Legends
- ARC Raiders
- Baldur's Gate 3
- Battlefield 6
- Call of Duty: Warzone
- Clash of Clans
- Clash Royale
- Counter-Strike 2
- Cyberpunk 2077
- Dota 2
- EA Sports FC 26
- Final Fantasy VII Rebirth
- Genshin Impact
- Horizon Forbidden West: Complete Edition
- League of Legends
- Marvel Rivals
- Marvel's Spider-Man 2
- Overwatch 2
- PUBG: Battlegrounds
- Pokémon Pokopia
- Resident Evil Requiem
- Roblox
- Star Wars Battlefront II
- Valorant
- Warhammer 40,000: Space Marine 2

For games where real imports succeeded, seeded placeholder patches were removed so the app now shows live source-backed patch data instead.

As of March 16, 2026, a live run on `gamebrief-eu` confirmed the scrapeable sources above still execute successfully after the Heroku migration. Dota 2 and Final Fantasy VII Rebirth were added on March 16, 2026. The currently blocked sources are listed below.

## Known Issues

### Fortnite

The official Fortnite news page currently returns a Cloudflare challenge / `403` to the scraper.

Source:
`https://www.fortnite.com/news`

Impact:

- automated scraping is currently blocked
- seeded placeholder data may still be the only patch data available

### Helldivers 2

The official Arrowhead Zendesk patch-notes section currently returns a Cloudflare challenge / `403` to the scraper.

Source:
`https://arrowhead.zendesk.com/hc/en-us/sections/12541983411100-Latest-patch-notes`

Impact:

- automated scraping is currently blocked
- GameBrief should treat this source as requiring an alternate endpoint or API for now

### Minecraft

The official Minecraft changelog section currently returns a Cloudflare challenge / `403` to the scraper.

Source:
`https://feedback.minecraft.net/hc/en-us/sections/360001186971-Release-Changelogs`

Impact:

- automated scraping is currently blocked
- GameBrief should treat this source as requiring an alternate endpoint or API for now

### Destiny 2

Bungie news is heavily JS-driven and the current scraper does not yet use a reliable official content endpoint.

Source:
`https://www.bungie.net/7/en/News`

Impact:

- automated scraping currently returns no real patch imports

### Published Dates

Most scrapers do not persist patch publish dates in the database.

Impact:

- "last 6 months" filtering is only reliable for sources where the index exposes publish dates and the scraper explicitly uses them
- adding a `published_at` column to `Patch` would improve sorting, filtering, and backfill accuracy

## Best Practices For Future Scrapers

- Prefer official publisher or developer sources.
- Prefer structured payloads such as `__NEXT_DATA__`, JSON endpoints, or RSS over brittle DOM scraping.
- De-duplicate only by stable source URL.
- Keep title filters specific enough to avoid importing general news.
- If the source exposes publish dates, use them.
- Add a job, importer, rake task, and tests together.
- Verify whether the site blocks bots before relying on simple `open-uri` scraping.

## Recommended Future Improvements

- Add `published_at` to `Patch`.
- Add scraper tests for source-specific parsing logic, especially for structured payloads.
- Add a backfill task that targets a configurable date window.
- Add monitoring or logging around scraper failures by source.
- Build source-specific fallback strategies for Fortnite and Destiny 2.
- Add a real admin role migration and UI for triggering `/admin/patch_scrapes`.

---

## Event Scraping

### Event Scraping Purpose

Document how event scraping works in GameBrief — which games have automated event scrapers, which use manual seeds, and how imports are run.

This section covers the `events` table only. Patch scraping is documented above.

### Event Scraping Architecture

Event scraping uses two layers, mirroring the patch pipeline:

1. `EventScrapers::*` — fetch and parse official news or announcement sources, returning an array of event hashes with `:title`, `:description`, and `:start_date`.
2. `EventImporters::*` — resolve the target `Game`, apply the future filter (`start_date.nil? || start_date >= Date.today`), and create or skip `Event` records.

Flow:

```text
Official source -> EventScraper -> EventImporter -> events table -> app UI
```

Key convention: if an article was published within `RECENT_DAYS` days and no specific future date is known, `start_date` is set to `nil`. The importer treats `nil` as "ongoing/active now" and always passes the future filter.

### Event Scraping Files

Event scrapers live in: `app/services/event_scrapers/`

Event importers live in: `app/services/event_importers/`

Rake tasks live in: `lib/tasks/events.rake`

Seeds use `seed_live_events` (calls the importer with `replace: true`) and `seed_event_series` (manual future events). Many games use both — scraped live events plus manual seeds for known future milestones.

### Event — Automated Scrapers

| Game | Scraper class | Source | App ID / URL |
| --- | --- | --- | --- |
| Apex Legends | `ApexLegendsEventScraper` | EA news page | `ea.com/games/apex-legends/news` |
| ARC Raiders | `ArcRaidersEventScraper` | arcraiders.com news | `arcraiders.com/news` |
| Counter-Strike 2 | `CounterStrike2EventScraper` | Steam Community Announcements | App ID 730 |
| Dota 2 | `Dota2EventScraper` | Steam Community Announcements | App ID 570 |
| EA Sports FC 26 | `EaSportsFc26EventScraper` | EA news page | `ea.com/games/ea-sports-fc/fc-26/news` |
| Genshin Impact | `GenshinImpactEventScraper` | HoYoLAB news API | `bbs-api-os.hoyolab.com` |
| GTA 5: Online | `GtaOnlineEventScraper` | Steam Community Announcements | App ID 271590 |
| Helldivers 2 | `Helldivers2EventScraper` | Steam Community Announcements | App ID 553850 |
| League of Legends | `LeagueOfLegendsEventScraper` | LoL news page | `leagueoflegends.com/en-us/news/` |
| Overwatch 2 | `Overwatch2EventScraper` | Steam Community Announcements | App ID 2357570 |
| PUBG: Battlegrounds | `PubgEventScraper` | Steam Community Announcements | App ID 578080 |
| Valorant | `ValorantEventScraper` | vlr.gg + playvalorant.com | — |
| Warhammer 40,000: Space Marine 2 | `SpaceMarine2EventScraper` | Steam Community Announcements | App ID 2183900 |

### Event — Manual Seeds Only (No Scraper)

| Game | Reason | Seeds |
| --- | --- | --- |
| Battlefield 6 | EA only posts when content launches, not in advance | Season 2 Phase 3, Season 3 |
| Call of Duty: Warzone | Same EA announce-at-launch pattern | Season 03, Season 03 Reloaded |
| Clash of Clans | Supercell blog shows past articles, no upcoming event feed | Clan Games ×2, April Season |
| Clash Royale | Same Supercell limitation | April Season, Global Tournament, May Season |
| Cyberpunk 2077 | Single-player, no live service events | 6th Anniversary (Dec 2026) |
| Destiny 2 | Steam API returns only weekly "This Week In Destiny" posts | Guardian Games, Next Episode, Solstice |
| Final Fantasy VII Rebirth | Single-player, no live service | 30th Anniversary (Jan 2027) |
| Fortnite | epicgames.com / fortnite.com return 403 | New Season, Fortnitemares, Winterfest |
| Horizon Forbidden West | Single-player, no live events | PC 2nd Anniversary, PS5 4th Anniversary |
| Marvel Rivals | marvelrivals.com is JS-rendered; Steam feed is patch notes only | Season 7 Launch, Season 7.5 Mid-Season |
| Minecraft | minecraft.net is JS-rendered; no RSS; Steam API returns 0 announcements | Spring 2026 Drop, Minecraft Live 2026 |
| Roblox | blog.roblox.com surfaces only developer-focused articles | Egg Hunt, RDC 2026 |

### Event — No Events (Cleared)

| Game | Reason |
| --- | --- |
| Marvel's Spider-Man 2 | Single-player, no DLC or live events announced |
| Star Wars Battlefront II | EA ended development April 2020; last Steam announcement 627 days ago |
| Pokémon Pokopia | Fictional demo game — placeholder events retained as-is |
| Resident Evil Requiem | Fictional demo game — placeholder events retained as-is |

### Event — Hybrid: Scraper + Manual Future Seeds

Several games use `seed_live_events` to pull current active events and `seed_event_series` to add known annual milestones that won't appear in feeds until announced:

| Game | Live scraper gets | Manual seeds add |
| --- | --- | --- |
| Dota 2 | TI announcement, recent patches | Battle Pass (~May), Diretide (~Oct) |
| EA Sports FC 26 | FUT promos, World Tour seasons | TOTS (~May) |
| Genshin Impact | Current version update | Next version date, Summer Archipelago |
| League of Legends | Current act, champion releases, First Stand | MSI (~May), World Championship (~Oct) |
| Overwatch 2 | Active season, seasonal events, XP boosts | Anniversary (~May) |
| PUBG: Battlegrounds | Anniversary events, Spring Fest, Global Series | PGC (~Nov) |
| Warhammer 40K: Space Marine 2 | Community events, Twitch drops, major updates | Warhammer Skulls Festival (~Jun) |

### Event Source Strategy Details

#### Steam Community Announcements API

Used for: Counter-Strike 2, Dota 2, GTA 5: Online, Helldivers 2, Overwatch 2, PUBG: Battlegrounds, Warhammer 40K: Space Marine 2.

Endpoint pattern:

```text
https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=<APP_ID>&count=20&feeds=steam_community_announcements
```

Each scraper defines `RECENT_DAYS`, `EVENT_PATTERN`, and `EXCLUDE_PATTERN`. The Steam API announces content at launch rather than in advance, so results get `nil` start dates. Known future events (e.g. annual championships) are added as manual seeds.

#### EA news pages (HTML scraping)

Used for: Apex Legends, EA Sports FC 26.

Each link's text embeds the article type prefix, a date string (`EA_DATE_PATTERN = /([A-Z][a-z]+ \d{1,2}, \d{4})/`), and the title concatenated together. The scraper strips the prefix and date to isolate the title. Articles within `RECENT_DAYS` get `start_date: nil`. EA publishes at launch, not in advance.

#### League of Legends news page (HTML scraping)

Used for: League of Legends. Source: `https://www.leagueoflegends.com/en-us/news/`

Each `a` tag's text embeds category + ISO 8601 timestamp + title+subtitle in camelCase. Pattern: `TIMESTAMP_PATTERN = /^([\w\s]+?)(\d{4}-\d{2}-\d{2}T[\d:\.Z]+)(.+)/`. Title is split from subtitle at the first lowercase→uppercase junction (`/(?<=[a-z0-9])(?=[A-Z])/`). A length guard (`< 8` or `> 80` chars) catches unsplit strings. `EXCLUDE_PATTERN` removes patch notes, TFT, merch, "New League Meta" guides, and regional splits (LCS/LEC/LCK/LPL).

#### HoYoLAB API

Used for: Genshin Impact.

```text
https://bbs-api-os.hoyolab.com/community/post/wapi/getNewsList?gids=2&page_size=20&type=1
```

Deduplicates by version key — maintenance preview, update details, and "what's new" articles all reference the same version and collapse to one event. `clean_title` strips promotional prefixes and normalises to "Genshin Impact — Version X Update".

#### ARC Raiders (HTML scraping)

Used for: ARC Raiders. Source: `arcraiders.com/news`. Fetches news index and filters by title keyword for early access, trial, season, or community content.

#### Valorant (vlr.gg + playvalorant.com)

Mixed source: VCT tournament data from vlr.gg, in-game event data from playvalorant.com.

### Event Rake Tasks

Full list of available event import tasks:

```bash
bin/rake events:import_apex_legends
bin/rake events:import_arc_raiders
bin/rake events:import_battlefield_6
bin/rake events:import_call_of_duty_warzone
bin/rake events:import_clash_of_clans
bin/rake events:import_clash_royale
bin/rake events:import_counter_strike_2
bin/rake events:import_destiny_2
bin/rake events:import_dota_2
bin/rake events:import_ea_sports_fc_26
bin/rake events:import_genshin_impact
bin/rake events:import_gta_online
bin/rake events:import_helldivers_2
bin/rake events:import_league_of_legends
bin/rake events:import_overwatch_2
bin/rake events:import_pubg
bin/rake events:import_space_marine_2
bin/rake events:import_valorant
```

Run all at once:

```bash
bin/rake events:import_all
```

`import_all` only runs games with automated scrapers. Manual-seed-only games are kept up to date by editing `db/seeds.rb` and re-running `db:seed`.

### Event Seeding Patterns

`db/seeds.rb` calls event logic in three patterns:

**Scraped only:**

```ruby
seed_live_events(game: cs2, importer_class: EventImporters::CounterStrike2EventImporter)
```

**Manual only:**

```ruby
game&.events&.destroy_all
seed_event_series(game: game, events: [...])
```

**Hybrid (scraped + known future milestones):**

```ruby
seed_live_events(game: lol, importer_class: EventImporters::LeagueOfLegendsEventImporter)
seed_event_series(game: lol, events: [
  { title: "MSI 2026", ..., start_date: DateTime.new(2026, 5, 1, 12, 0, 0) },
  { title: "World Championship 2026", ..., start_date: DateTime.new(2026, 10, 3, 12, 0, 0) }
])
```

`seed_live_events` calls the importer with `replace: true`, destroying existing events before importing. `seed_event_series` uses `find_or_initialize_by(title:)` so it is safe to re-run.

### Event Scraping Known Limitations

**Announce-at-launch pattern (EA, Steam):** Most publishers post announcements when content goes live, not in advance. Scrapers return `nil` start dates for all events. Known future events must be seeded manually.

**Fortnite (403 blocked):** `fortnite.com` and `epicgames.com` return 403 to all non-browser requests. No alternative API found. Events are seeded manually as known annual beats.

**Minecraft (JS-rendered):** `minecraft.net` is built on Adobe Experience Manager and is fully JS-rendered. The Steam API returns 0 announcements. No RSS or Atom feed exists. Events are seeded manually.

**Marvel Rivals (JS-rendered):** `marvelrivals.com` requires JS execution. The Steam feed contains only patch notes. Events are seeded manually based on the known 8-week season cadence.

**Clash of Clans / Clash Royale (past articles only):** The Supercell blog scraper reads past published articles correctly but Supercell does not publish a forward-looking events calendar. Event dates are seeded manually.

### Event Scraping Future Improvements

- Add a `published_at` or `ends_at` column to `Event` to support expiry filtering.
- Add a Heroku Scheduler job that runs `events:import_all` daily alongside `patches:scrape_all`.
- Investigate Fortnite alternatives (unofficial community APIs, Epic Developer portal).
- Add scraper tests for event title parsing logic (especially the LoL camelCase split and Genshin version deduplication).
