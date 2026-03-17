# GameBrief — Rails Setup Guide

> Last updated: 2026-03-17

## Stack

- Ruby on Rails 8.1 + PostgreSQL
- Devise (email/password auth)
- OmniAuth + omniauth-google-oauth2 (Google OAuth)
- Bootstrap 5, Simple Form, Sass
- Hotwire (Turbo + Stimulus)
- Solid Cache / Solid Queue / Solid Cable
- Kaminari (pagination)
- Redcarpet (markdown rendering)
- Nokogiri (web scraping)
- `anthropic` gem (Claude Opus 4.6)
- `ruby_llm` gem (GPT-4o)
- dotenv-rails (local env vars)

## Environment Variables

Local `.env` file:

```bash
GOOGLE_OAUTH_CLIENT_ID=...
GOOGLE_OAUTH_CLIENT_SECRET=...
TWITCH_CLIENT_ID=...
TWITCH_CLIENT_SECRET=...
OPENAI_API_KEY=...
ANTHROPIC_API_KEY=...
```

`RAILS_MASTER_KEY` lives in `config/master.key` (not in `.env`).

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

# Patch scraping
bin/rake patches:scrape_all

# Event importing
bin/rake events:import_all
```

## Authentication Setup

Devise is installed and configured with:

- Email/password (standard Devise)
- Google OAuth via `users/omniauth_callbacks_controller`
- Custom `users/registrations_controller` to allow profile updates without password re-entry

Required env vars: `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`

The Google OAuth callback URL pattern:

```text
https://your-domain.com/users/auth/google_oauth2/callback
```

`OmniAuth.config.full_host` is hardcoded in `config/initializers/devise.rb` to `https://gamebrief.live`. Update this if the production hostname changes.

## IGDB Setup

IGDB uses Twitch for auth. Required env vars: `TWITCH_CLIENT_ID`, `TWITCH_CLIENT_SECRET`

The `IgdbClient` service at `app/services/igdb_client.rb` handles API requests and game import.

## AI Setup

Two providers are used:

- **Claude Opus 4.6** via the `anthropic` gem — requires `ANTHROPIC_API_KEY`
- **GPT-4o** via the `ruby_llm` gem — requires `OPENAI_API_KEY`

## Database

PostgreSQL locally and in production. Use `bin/rails db:create db:migrate` for initial setup.

## Heroku Setup

Before deployment:

1. Create a Heroku app (EU region: `heroku create APP_NAME --region eu`)
2. Add Heroku Postgres: `heroku addons:create heroku-postgresql:essential-0`
3. Set all Config Vars (see above, plus `RAILS_MASTER_KEY`)
4. Update Google OAuth callback URL in Google Cloud Console
5. Push code and run `heroku run bin/rails db:migrate`

Full deployment runbook: [8GameBrief_Deployment_Guide.md](8GameBrief_Deployment_Guide.md)
