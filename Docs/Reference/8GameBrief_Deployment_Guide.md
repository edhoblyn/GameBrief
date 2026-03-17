# GameBrief — Deployment Guide

> Last updated: 2026-03-17

## Deployment Platform

GameBrief is deployed on **Heroku** (EU region, app: `gamebrief-eu`).

**Procfile** (already present in repo):

```text
web: bundle exec puma -C config/puma.rb
```

## Required Environment Variables

Set these in Heroku Config Vars:

```bash
RAILS_MASTER_KEY
GOOGLE_OAUTH_CLIENT_ID
GOOGLE_OAUTH_CLIENT_SECRET
TWITCH_CLIENT_ID
TWITCH_CLIENT_SECRET
OPENAI_API_KEY
ANTHROPIC_API_KEY
```

`DATABASE_URL` is set automatically by Heroku Postgres.

## Heroku Setup Steps

1. Create the app in the EU region: `heroku create APP_NAME --region eu`
2. Add Heroku Postgres: `heroku addons:create heroku-postgresql:essential-0`
3. Set all Config Vars (see above)
4. Connect to the GitHub repo or push via Git remote
5. Run database migrations
6. Seed the database
7. Run scrapers to populate real patch and event data
8. Open the app and verify

```bash
heroku run bin/rails db:migrate
heroku run bin/rails db:seed
heroku run bin/rake patches:scrape_all
heroku run bin/rake events:import_all
heroku open
heroku logs --tail
```

## Google OAuth

Add the production callback URL to Google Cloud Console:

```text
https://gamebrief.live/users/auth/google_oauth2/callback
```

`OmniAuth.config.full_host` is hardcoded in `config/initializers/devise.rb` to `https://gamebrief.live`. Update this if the production hostname changes.

## Scheduled Jobs

Use **Heroku Scheduler** for recurring imports:

| Command | Recommended cadence |
| --- | --- |
| `bin/rake patches:scrape_all` | Daily |
| `bin/rake events:import_all` | Daily |

## Active Storage

User-uploaded avatars and cover images are stored on the **local disk service** in production. A Heroku Postgres backup will not copy these files. Plan a separate file migration if uploaded files matter during any app migration.

## Admin Access

After seeding, promote the first admin from the Rails console:

```ruby
User.find_by(email: "you@example.com").update!(role: "admin")
```

## Pre-Launch Checklist

- [ ] Heroku app created in EU region
- [ ] Heroku Postgres attached
- [ ] All Config Vars set
- [ ] `bin/rails db:migrate` run
- [ ] `bin/rails db:seed` run
- [ ] `bin/rake patches:scrape_all` run
- [ ] `bin/rake events:import_all` run
- [ ] Google OAuth production callback URL added
- [ ] At least one admin user promoted
- [ ] App boots and home page loads
- [ ] Google sign-in works
- [ ] Games, patches, and events pages load correctly
- [ ] Heroku Scheduler jobs created

## Useful Commands

```bash
heroku logs --tail -a gamebrief-eu
heroku run bin/rails console -a gamebrief-eu
heroku pg:backups:capture -a gamebrief-eu
heroku ps -a gamebrief-eu
```

## Full Migration Runbook

For migrating between Heroku regions or apps, see [Heroku_EU_Migration_Checklist.md](../Heroku_EU_Migration_Checklist.md).
