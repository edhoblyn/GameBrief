# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GameBrief is a short 2-week student Rails project. It helps casual gamers understand game updates quickly through AI-generated patch note summaries. **Prioritize simplicity and a working demo over advanced architecture.**

## Common Commands

```bash
# Start the server
bin/rails server

# Database
bin/rails db:migrate
bin/rails db:seed        # Wipes and re-seeds with demo data (demo@test.com / 123456)

# Console
bin/rails console

# Linting / security
bundle exec rubocop
bundle exec brakeman
bundle exec bundler-audit
```

## Architecture

Standard Rails 8.1 MVC app with PostgreSQL, Devise auth, Bootstrap 5, and simple_form.

### Authentication
- `ApplicationController` requires `authenticate_user!` on every action — skip it per-controller where public access is needed.
- Devise handles email/password auth. Google OAuth (omniauth-google-oauth2) is installed but not yet wired up — needs `OmniauthCallbacksController` and `provider`/`uid` columns added to users.

### Data Flow
1. Games are imported from **IGDB API** via a service object (`app/services/igdb_client.rb` — not yet created). IGDB uses Twitch credentials for auth.
2. Patches and Events are entered manually (no automation needed for MVP).
3. AI summaries are generated from `patches.content` and saved as `PatchSummary` records. Three summary types: Quick Summary, Casual Impact, Should I Log In.

### Key Model Relationships
- `User` → has_many `Favourite` → has_many `Game` (through favourites)
- `Game` → has_many `Patch`, has_many `Event`
- `Patch` → has_many `PatchSummary`
- `Event` → has_many `Reminder` (belongs_to `User`)

### What's Built vs. Still Needed

**Built:** All 7 DB tables migrated, all models, `GamesController` (index/show), basic game views, Devise, shared navbar/flash partials, seed data.

**Still needed:**
- Google OAuth (`OmniauthCallbacksController`, add `provider`/`uid` to users)
- `IgdbClient` service + rake task to import games
- `FavouritesController` (create/destroy, no index/show needed)
- `PatchesController` + views (show patch + its summaries)
- `EventsController` + views
- `RemindersController` (create/destroy)
- AI summary generation (Claude API → `PatchSummary` records)

### Routes Pattern
The planned route structure (partially implemented):
```
root → games#index
resources :games, only: [:index, :show]
resources :patches, only: [:show]
resources :events, only: [:show]
resources :favourites, only: [:create, :destroy]
resources :reminders, only: [:create, :destroy]
devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }
```

## Environment Variables

Stored in `.env` (development) and Heroku Config Vars (production):
```
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET
TWITCH_CLIENT_ID       # For IGDB API access
TWITCH_CLIENT_SECRET
RAILS_MASTER_KEY
```

## Deployment

Target: Heroku + Heroku Postgres. There is no Procfile yet — add `web: bundle exec rails server -p $PORT` when deploying.
