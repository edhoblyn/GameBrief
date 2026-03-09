# GameBrief — IGDB Integration Guide

## Purpose

Use IGDB as the **game catalogue source** for GameBrief.

IGDB should populate the `games` table with:
- name
- slug
- cover image
- optional metadata such as genres and platforms

## What IGDB Is For

Use IGDB for:
- importing games
- searching game data
- getting cover art and metadata

Do not use IGDB for:
- patch notes
- live events
- reminders

## Credentials Needed

Local `.env`:
- TWITCH_CLIENT_ID
- TWITCH_CLIENT_SECRET

Heroku Config Vars:
- TWITCH_CLIENT_ID
- TWITCH_CLIENT_SECRET

## Integration Pattern

IGDB API → `IgdbClient` service object → Rails models → database

## Suggested Workflow

1. Create `IgdbClient`
2. Add method to search/import games
3. Save imported records into `games`
4. Test locally
5. Add credentials to Heroku
6. Test again in production

## Deployment Note

If IGDB works locally but not on Heroku, check:
- Heroku Config Vars
- logs
- missing credentials
