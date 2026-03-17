# GameBrief — Data Import Strategy

> Last updated: 2026-03-17

## Purpose

Document how GameBrief obtains and stores external data: games, patches, and live events.

## Data Sources

### Game Data

Source: **IGDB API** (via Twitch credentials)

Imported fields: name, slug, cover_image, free_to_play, single_player, multiplayer, genre

Import is handled by `IgdbClient` (`app/services/igdb_client.rb`) and called during `db:seed`.

### Patch Notes

Source: **Automated scrapers** (29 scrapers across 25+ games)

Each game has a dedicated `Scrapers::*` class and a `PatchImporters::*` class. De-duplication is by `source_url`. The shared `PatchScrapeRunner` service orchestrates all scrapers.

Blocked sources (Fortnite, Helldivers 2, Minecraft, Destiny 2) fall back to manually seeded placeholder data.

Stored fields: title, content, source_url, published_at, game_id

### Events

Source: **Automated event importers** (18 importers) + **manual seeds**

Each game has a dedicated `EventScrapers::*` class and an `EventImporters::*` class. The shared `EventImportRunner` orchestrates all importers.

Many games use a hybrid approach: automated scrapers for live/active events, manual seeds for known future milestones (annual events, championships).

Stored fields: title, description, start_date, game_id

## Import Flow

```text
External source → Scraper/Importer service → Rails model → database → app UI
```

## Running Imports

```bash
# Patch scraping (all sources)
bin/rake patches:scrape_all

# Single game
bin/rake patches:scrape_valorant

# Event importing (all sources)
bin/rake events:import_all

# Single game
bin/rake events:import_league_of_legends
```

Full task lists: [11GameBrief_Scraping_Guide.md](11GameBrief_Scraping_Guide.md)

Admin dashboard also provides UI-based triggers at `/admin/dashboard`.

## Production Import Flow on Heroku

```bash
heroku run bin/rails db:migrate
heroku run bin/rails db:seed
heroku run bin/rake patches:scrape_all
heroku run bin/rake events:import_all
```

Recurring imports are scheduled via **Heroku Scheduler**:

- `bin/rake patches:scrape_all` — daily
- `bin/rake events:import_all` — daily

## Seeding Strategy

`db/seeds.rb` handles:

1. Wipes and recreates the demo user and featured gamer profiles
2. Imports games from IGDB
3. Seeds patches — preserves real scraped data where it exists; removes placeholder patches for those games
4. Seeds events — uses `seed_live_events` (calls importer) and `seed_event_series` (manual future milestones)

The seed file is safe to re-run but is a full reset — do not run `db:seed` in production unless you want to wipe existing user data.
