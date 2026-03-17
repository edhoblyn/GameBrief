# GameBrief — Admin Workflow Guide

> Last updated: 2026-03-17

## Purpose

Allow admins to manage game data, trigger patch scrapers, run event importers, and manage user roles from a dedicated admin dashboard.

## Accessing the Admin Dashboard

Route: `GET /admin/dashboard`

Access is protected by `current_user.admin?`. Users with `role: "admin"` in the `users` table have access. All other users receive a redirect.

---

## Admin Responsibilities

### Managing Games

Games are imported from IGDB via `IgdbClient`. Seeds handle initial import. After seeding, admins can verify:

- cover image loaded correctly
- slug is correct
- game name matches expected

Game suggestions submitted by users are stored in `game_suggestions` and visible to admins as a signal for which games to add next.

### Triggering Patch Scrapes

From the admin dashboard, admins can:

- Run a single scraper for a specific game (`POST /admin/patch_scrapes` with a `source` param)
- Run all enabled scrapers at once (`POST /admin/patch_scrapes/run_all`)

Both actions use the shared `PatchScrapeRunner` service. Results are stored in a cache-based log (`AdminPatchScrapeLogStore`) and rendered back into the dashboard after the run.

Available scrapers are listed in [11GameBrief_Scraping_Guide.md](11GameBrief_Scraping_Guide.md).

### Triggering Event Imports

Same pattern as patch scrapes:

- Run a single event importer (`POST /admin/event_imports` with a `source` param)
- Run all enabled importers (`POST /admin/event_imports/run_all`)

Both use `EventImportRunner`. Results are rendered back into the dashboard.

### Managing Admins

Admins can promote and demote other users:

- **Promote**: `POST /admin/users` with the target user's email
- **Demote**: `DELETE /admin/users/:id`

Guard: the last remaining admin cannot be removed (enforced in `Admin::UsersController`).

### Clearing Chat History

`DELETE /admin/chat_history` clears the current admin's own chat records.

---

## Rake Tasks (Command Line)

All scraper and importer operations are also available as rake tasks for Heroku Scheduler or manual one-off runs.

```bash
# Patch scraping
bin/rake patches:scrape_all
bin/rake patches:scrape_<game_slug>   # e.g. scrape_valorant

# Event importing
bin/rake events:import_all
bin/rake events:import_<game_slug>    # e.g. import_league_of_legends
```

Full task lists are in [11GameBrief_Scraping_Guide.md](11GameBrief_Scraping_Guide.md).

---

## Heroku One-Off Admin Commands

```bash
heroku run bin/rails db:migrate
heroku run bin/rails db:seed
heroku run bin/rake patches:scrape_all
heroku run bin/rake events:import_all
heroku logs --tail
```

---

## Log Output

Scrape and import log output is stored using `Rails.cache` with a 12-hour TTL. The dashboard reads from the cache and displays the most recent run log after each action.

---

## Adding a New Admin

From the Rails console in production:

```ruby
user = User.find_by(email: "someone@example.com")
user.update!(role: "admin")
```

Or via the in-app admin dashboard by entering the user's email in the "Add Admin" form.
