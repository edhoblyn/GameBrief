# GameBrief — IGDB Integration Guide

> Last updated: 2026-03-17

## Purpose

Use IGDB as the **game catalogue source** for GameBrief.

IGDB populates the `games` table with:

- name
- slug
- cover_image
- free_to_play
- single_player
- multiplayer
- genre

## Status

**Built.** `IgdbClient` service is implemented at `app/services/igdb_client.rb` and is called in `db/seeds.rb` to import the full game catalogue.

## What IGDB Is For

Use IGDB for:

- importing games
- searching game data
- getting cover art and metadata

Do not use IGDB for:

- patch notes (handled by scrapers)
- live events (handled by event importers)
- reminders

## Credentials

Local `.env`:

```bash
TWITCH_CLIENT_ID=...
TWITCH_CLIENT_SECRET=...
```

Heroku Config Vars (same keys).

## Integration Pattern

```text
IGDB API → IgdbClient → Game model → games table
```

IGDB uses Twitch OAuth for API auth. `IgdbClient` handles the token exchange automatically.

## Running an Import

Game import runs as part of seeding:

```bash
bin/rails db:seed
```

Or from the Rails console:

```ruby
IgdbClient.new.import_games
```

In production:

```bash
heroku run bin/rails db:seed
```

Note: `db:seed` wipes and re-seeds the entire database including demo users and patch/event data. Run with care in production — use only for full resets.

## Troubleshooting

If IGDB works locally but not on Heroku, check:

- Heroku Config Vars have `TWITCH_CLIENT_ID` and `TWITCH_CLIENT_SECRET`
- `heroku logs --tail` for auth errors
- Twitch app credentials are still active in the Twitch developer console
