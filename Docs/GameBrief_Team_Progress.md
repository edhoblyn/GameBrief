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

## Round 3 — Bug Fixes + Page Polish ✅

### Person 1 — Ed — Heroku + Demo Prep

- Added Heroku callback URI to Google Cloud Console
- Fixed Google OAuth CSRF error (`provider_ignores_state: true`)
- Fixed Google OAuth callback URL scheme on Heroku (`OmniAuth.config.full_host`)
- Identified missing `GOOGLE_OAUTH_CLIENT_ID` config var on Heroku — set

### Person 2 — Hortense — Styling Round 2

- Dashboard link added to navbar
- `patches/show.html.erb` styled — patch notes block, summary card
- `games/show.html.erb` and `games/index.html.erb` restyled
- `events/show.html.erb` and `events/index.html.erb` styled
- Navbar rebuilt with cleaner layout and hover effects

### Person 3 — Baptiste — Fix + Polish AI Summaries

- Removed `thinking: { type: "adaptive" }` from `SummaryService` — was causing API error
- Generate Summary button now only shown if no summary exists yet
- Homepage added with hero section and styling

### Person 4 — Bianca — Dashboard Polish

- Cover images shown on dashboard game cards
- Upcoming events section added to dashboard
- Events index styled with card layout
- Dashboard layout improved with styling

---

Last updated: Round 3 complete, Round 4 not yet started
