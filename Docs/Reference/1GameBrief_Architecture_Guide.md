# GameBrief — Architecture Guide

> Last updated: 2026-03-17

## Project Goal

GameBrief helps casual gamers understand live-service game updates quickly.

The app focuses on:
- games users care about
- patch notes with AI summaries
- AI-powered patch chatbot
- live events with reminders
- social features (friends, posts, profile)

## Main Architecture

Standard Rails 8.1 MVC app with PostgreSQL, Devise auth, Bootstrap 5, Hotwire (Turbo + Stimulus), and Simple Form.

### Core Flow

1. User signs in with email/password or Google OAuth
2. User browses games imported from IGDB
3. User follows games
4. User opens a game page — sees latest patches and upcoming events
5. User reads AI patch summaries or chats with the AI about a patch
6. User saves reminders for events
7. User manages their profile and finds friends

## Data Sources

### Games
Games are imported from **IGDB** via Twitch credentials (`IgdbClient` service). Fields imported: name, slug, cover_image, free_to_play, single_player, multiplayer, genre.

### Patches
Patch notes are ingested automatically via dedicated scrapers. 29 scrapers exist across 25+ games. Blocked sources fall back to manual seeding.

### Events
Events come from automated scrapers (18 event importers) or manual seeds. Many games use a hybrid approach: scrapers for live events + manual seeds for known future milestones.

## Authentication and Authorisation

- Devise handles email/password auth (signup, login, password reset)
- Google OAuth via OmniAuth (`users/omniauth_callbacks_controller`)
- `ApplicationController` requires `authenticate_user!` globally; public exceptions carved out for homepage and game browsing
- Admin role stored on `users.role` column; checked via `current_user.admin?`

## AI Integration

Two AI providers are used:

| Use case | Provider | Gem |
| --- | --- | --- |
| Patch summaries (3 types) | Claude Opus 4.6 | `anthropic` |
| Event summaries | Claude Opus 4.6 | `anthropic` |
| Patch presentation formatting | GPT-4o | `ruby_llm` |
| Patch chatbot responses | GPT-4o | `ruby_llm` |

## Key Model Relationships

- `User` → has_many `Favourite` → has_many `Game` (through favourites)
- `User` → has_many `Reminder` → has_many `Event` (through reminders)
- `User` → has_many `Friendship` (bidirectional), has_many `Post`, has_many `Like`, has_many `Chat`
- `Game` → has_many `Patch`, has_many `Event`
- `Patch` → has_many `PatchSummary`, has_many `Chat`
- `Post` → has_many `Like`
- `Chat` → has_many `Message`

## Services

Located in `app/services/`:

| File | Purpose |
| --- | --- |
| `igdb_client.rb` | IGDB API import via Twitch credentials |
| `summary_service.rb` | Claude Opus 4.6 — 3 patch summary types |
| `patch_presentation_service.rb` | GPT-4o — structured patch formatting |
| `patch_presentation_fallback_service.rb` | Fallback formatting without AI |
| `event_summary_service.rb` | Claude Opus 4.6 — event summaries |
| `patch_scrape_runner.rb` | Orchestrates all 29 patch scrapers |
| `event_import_runner.rb` | Orchestrates all 18 event importers |
| `scrapers/` | Individual patch scrapers per game |
| `patch_importers/` | Individual patch importers per game |
| `event_scrapers/` | Individual event scrapers per game |
| `event_importers/` | Individual event importers per game |
| `admin_patch_scrape_log_store.rb` | Cache-based log storage for admin runs |
| `admin_event_import_log_store.rb` | Cache-based log storage for admin runs |

## Real-time Features

- Patch chatbot uses `ActionController::Live::SSE` for streaming responses
- Patch presentation uses Turbo frame polling to show progress while AI generates structured output
- Turbo Stream renders new messages in the chat UI without full page reload

## Deployment

- **Heroku** (EU region, `gamebrief-eu`)
- **Heroku Postgres** for production database
- **Procfile** present: `web: bundle exec puma -C config/puma.rb`
- Active Storage on local disk service (uploaded avatars/cover images)
- Scheduled scrapes via Heroku Scheduler (`bin/rake patches:scrape_all`, `bin/rake events:import_all`)

## Architectural Principles

- Keep the app simple and follow Rails conventions
- Avoid unnecessary services unless they clearly help
- Use IGDB only for game catalogue data
- Keep patch and event workflows separate from IGDB
- Admin tooling lives under the `admin/` namespace behind `current_user.admin?`
