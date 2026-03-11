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

- Marvel Rivals
- Call of Duty: Warzone
- Fortnite
- Apex Legends
- EA Sports FC 26
- Helldivers 2
- Destiny 2
- Minecraft
- Valorant
- Roblox
- Clash Royale
- Clash of Clans

## Current Source Strategy

### EA / official news pages

Used for:

- Apex Legends
- EA Sports FC 26

Pattern:

- scrape official EA news index
- filter links by title pattern
- fetch article page
- extract title and main content

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

### Generic HTML extraction

Used for:

- Warzone
- Helldivers 2
- Minecraft
- Valorant
- Marvel Rivals

Pattern:

- fetch index page
- collect matching links
- fetch article page
- extract content from `main`, `article`, or similar container

## Manual Commands

Run a single scraper:

```bash
bin/rake patches:scrape_ea_sports_fc_26
```

Examples:

```bash
bin/rake patches:scrape_warzone
bin/rake patches:scrape_valorant
bin/rake patches:scrape_clash_royale
bin/rake patches:scrape_clash_of_clans
bin/rake patches:scrape_roblox
```

Run multiple scrapers:

```bash
bin/rake patches:scrape_apex_legends patches:scrape_ea_sports_fc_26 patches:scrape_valorant
```

Run all supported scrapers:

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
- Call of Duty: Warzone
- Clash of Clans
- Clash Royale
- EA Sports FC 26
- Helldivers 2
- Marvel Rivals
- Minecraft
- Roblox
- Valorant

For games where real imports succeeded, seeded placeholder patches were removed so the app now shows live source-backed patch data instead.

## Known Issues

### Fortnite

The official Fortnite news page currently returns a Cloudflare challenge / `403` to the scraper.

Source:
`https://www.fortnite.com/news`

Impact:

- automated scraping is currently blocked
- seeded placeholder data may still be the only patch data available

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
