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
- Identified and set missing `GOOGLE_OAUTH_CLIENT_ID` config var on Heroku
- Google login confirmed working on live Heroku URL
- Full demo walkthrough completed — crashes noted and reported
- `heroku run rails db:seed` run after each teammate merge

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

## Round 4 — New Features (partial)

### Person 3 — Baptiste — Multiple Summary Types

- `summary_type` string column added to `patch_summaries` table (migration `20260310112431`)
- `SummaryService` updated to accept `summary_type` argument with distinct Claude prompts for each type
- `PROMPTS` and `LABELS` hashes added covering Quick Summary, Casual Impact, Should I Log In?
- `patches/show.html.erb` loops through all 3 summary types — each displayed in its own labelled card with a Generate button
- Seeds updated to create all 3 summary types for every patch

### Person 4 — Bianca — Events Index + Reminders List

- `events/index.html.erb` styled with a card grid showing game name, event title and date
- "My Reminders" section added to the dashboard with event cards, game name, date, and empty state message
- "Upcoming Events" section on `games/show.html.erb` links through to the event page
- Count badges added to the dashboard for followed games and reminders

### Person 1 — Ed — Search + Heroku Checks

- Search bar added to `games/index.html.erb` — filters by name, preserves query in input field
- `GamesController#index` updated with case-insensitive `ILIKE` filter on `params[:query]`
- Full demo walkthrough completed on Heroku — no broken pages found
- `heroku run rails db:seed` confirmed working with all 12 games and demo data
- Demo user (`demo@test.com` / `123456`) confirmed working on Heroku

### Person 2 — Ed (covering Hortense) — Error Pages

- Custom `ErrorsController` created with `not_found` and `server_error` actions — auth skipped on both
- `config.exceptions_app = self.routes` added to `config/application.rb`
- `/404` and `/500` routes added to `config/routes.rb`
- `app/views/errors/404.html.erb` — "Page not found" with link back home
- `app/views/errors/500.html.erb` — "Something went wrong" with link back home
- `_errors.scss` created and imported — styled to match dark theme with large purple error code

---

## Round 5 — Polish + Extra Features (partial)

### Person 1 — Ed — Games Index Polish + Finishing Touches

- `genre` column added to `games` table as a PostgreSQL array (`array: true, default: []`) — supports multi-genre per game
- Genre data set on all 12 games using raw SQL with correct PG array literal format (`{"Shooter","Battle Royale"}`)
- Genre filter buttons added to `games/index.html.erb` — 7 categories: Shooter, Battle Royale, Strategy, Sports, Sandbox, Simulation, Mobile
- `GamesController#index` filters by genre using `? = ANY(genre::text[])` PostgreSQL query
- Sort options added: A–Z and Most Followed (`left_joins(:favourites).group.order COUNT DESC`)
- Footer added to `application.html.erb` — GameBrief name, current year, team names
- `loading="lazy"` added to all cover images in games index
- `_filter_btn.scss` and `_footer.scss` created and imported
- `dashboard_path` bug fixed in `pages/home.html.erb` — changed to `games_path` (route didn't exist)
- Error templates bug fixed — `ErrorsController` now explicitly renders `errors/404` and `errors/500`

---

## Round 6 — Stretch Features (partial)

### Stretch Task 3 — AI Event Summary — Baptiste

- `summary` text column added to the `events` table
- `EventSummaryService` created — sends event title + description to Claude and returns a single sentence
- `generate_summary` POST action added to `EventsController` with route wired up
- "Summarise Event" button added to `events/show.html.erb` — generates and saves the summary on click
- Summary displayed at the top of the event page when it exists

---

## Round 7 — Team Feature Requests (partial)

### Task A — My Profile + Sidebar — Baptiste

- "Dashboard" renamed to "My Profile" — navbar link, route (`my_profile_path`), page title, and internal links updated
- "My Game's Patches" section added to My Profile — recent patches from followed games with links
- "My Reminders" section shows all events the user has set reminders for
- Sidebar navigation built for the My Profile page: My Games, My Patches, My Events, Communities, My Recommendations
- Top navbar hidden on the My Profile page — sidebar replaces it for navigation
- Empty state messages shown when no games are followed or no reminders are set

### Task B — Patches Index + AI Chatbot — Baptiste

- Standalone `patches/index` page created (not scoped to a single game) — shows patches from followed games first, then all other patches
- "Patches" link added to the main navbar
- `Chat` model and `chats` table created — belongs to `patch` and `user`, has many `messages`
- `Message` model and `messages` table created — `role` (user/assistant), `content` (text)
- `MAX_USER_MESSAGES = 10` limit enforced per chat to prevent abuse
- `ChatsController#create` — finds or creates a chat between the current user and a patch
- `MessagesController#create` — saves user message, calls RubyLLM (GPT-4o) for assistant response, streams reply via Turbo Streams
- Conversation history built from all prior messages and passed as context on each request
- Custom system instructions include the patch content so the chatbot answers questions about that specific patch
- Chatbot UI added to `patches/show.html.erb` — collapsible panel with message history and input form

---

## 2026-03-11 Session — Scraping Expansion + Profile Refresh (partial)

### Person 1 — Ed — Scraping System Expansion

- Marvel Rivals proof of concept completed end-to-end: `source_url` added to `patches`, scraper/importer wired up, duplicate prevention added, weekly automation added
- Scraper support expanded beyond Marvel Rivals to 11 more games: Warzone, Fortnite, Apex Legends, EA Sports FC 26, Helldivers 2, Destiny 2, Minecraft, Valorant, Roblox, Clash Royale, Clash of Clans
- Shared `PatchScrapeRunner` service added so manual runs, scheduled runs, and future admin-triggered scrapes all use the same execution path
- `patches:scrape_all` added and hardened so one source failure does not stop the rest of the import run
- Scraping guide written and then updated with current source strategy, Heroku scheduling approach, blocked-source notes, and known limitations
- Seeds updated to preserve real scraped patch data and remove placeholder patches when live imported records exist
- Game and patch pages updated so scraped patches are shown before fallback/manual placeholder patches
- EA Sports FC seed data updated from FC 24 to FC 26 and the cover image refresh migration added

### Person 2 — Bianca — My Profile Refresh

- `my_profile.html.erb` rebuilt into a social-style layout with sidebar, header, tabs, recommendations, and community sections
- `social_feed_controller.js` added for tab switching plus like/repost interaction states
- My Profile reminders list now shows linked upcoming events with dates
- Sidebar/avatar handling on the profile page now falls back cleanly when the user has no avatar image
- Find Friends flow linked into the profile navigation

### Team — UI / Stability Fixes

- Event page reminder button layout cleaned up
- Events index styling adjusted
- Chatbot UI accessibility tweaked
- Heroku scraping flow checked again after scheduler/queue changes

---

Last updated: 2026-03-11 session added | Round 4 ✅ (Hortense mobile check ⬜) | Round 5 Ed ✅ tasks 1–6 | Round 5 others ⬜ | Round 6 Stretch Task 3 ✅ | Round 7 Tasks A + B ✅ | Scraping expansion ✅ partial blocked-source follow-up ⬜
