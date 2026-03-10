# GameBrief — Team Progress

---

## Project Foundation ✅

- Rails 8.1 app set up with PostgreSQL
- All 7 database tables migrated: users, games, favourites, patches, patch_summaries, events, reminders
- All models created with associations
- Devise email/password authentication
- Shared navbar and flash partials
- Root route → games#index
- Seed file with demo user, real game data, patches, summaries and events

---

## Round 1 — Core Features ✅

### Person 1 — Bianca — Authentication

- Devise installed and configured
- Email/password login and signup working
- `authenticate_user!` applied globally in ApplicationController
- Google OAuth wired up: `OmniauthCallbacksController` created, routes updated, `from_omniauth` on User model, `provider`/`uid` migration added
- `:omniauthable` added to User model
- App deployed to Heroku, database migrated and seeded
- `ANTHROPIC_API_KEY` added to Heroku config vars

### Person 2 — Ed — Games + IGDB

- `IgdbClient` service built with Twitch OAuth token fetch and game search
- Seeds import real games from IGDB with cover images
- `games/index.html.erb` — hero section and card grid with cover images
- `games/show.html.erb` shows game detail, patches, follow/unfollow button, and upcoming events
- Game model has all associations: patches, events, favourites

### Person 3 — Hortense — Patches + Summaries + Styling

- `Patch` model has `belongs_to :game` and `has_many :patch_summaries`
- `PatchSummary` model has `belongs_to :patch`
- `PatchesController` with index (scoped to game) and show (includes summaries)
- `patches/show.html.erb` displays patch notes and AI summary cards with Generate Summary button
- `patches/index.html.erb` lists patches for a game
- Routes set up with nested patches under games
- Navbar rebuilt — GameBrief brand, real links, clean dropdown
- Games index fully styled with card grid and cover images
- Events show page styled with badges and calendar button

### Person 4 — Baptiste — Events + Favourites + Reminders + AI

- `FavouritesController` with create and destroy
- Follow/unfollow buttons on `games/show.html.erb`
- `EventsController` with index and show, loads `@reminder` for current user
- `events/show.html.erb` displays event detail, Google Calendar link, Set/Remove Reminder buttons
- `events/index.html.erb` lists events
- `RemindersController` with create and destroy
- Reminder model has `belongs_to :user` and `belongs_to :event`
- `SummaryService` built using Claude API (`claude-opus-4-6`)
- `generate_summary` action in `PatchesController` with route wired up
- Dashboard page and controller action built, route added

---

## Round 2 — Polish + Integration ✅

All Round 2 tasks finished. See Round 1 completed work above for details.

---

Last updated: Round 2 complete, Round 3 and Round 4 in progress
