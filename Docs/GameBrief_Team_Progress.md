# GameBrief — Team Progress & Task Tracker

---

## Completed So Far

### Project Foundation

- Rails 8.1 app set up with PostgreSQL
- All 7 database tables migrated: users, games, favourites, patches, patch_summaries, events, reminders
- All models created with associations
- Devise email/password authentication
- Shared navbar and flash partials
- Root route → games#index
- Seed file with demo user, real game data, patches, summaries and events

### Person 1 — Bianca — Authentication ✅

- Devise installed and configured
- Email/password login and signup working
- `authenticate_user!` applied globally in ApplicationController
- Google OAuth wired up: `OmniauthCallbacksController` created, routes updated, `from_omniauth` on User model, `provider`/`uid` migration added
- `:omniauthable` added to User model
- App deployed to Heroku, database migrated and seeded
- `ANTHROPIC_API_KEY` added to Heroku config vars

### Person 2 — Ed — Games + IGDB ✅

- `IgdbClient` service built with Twitch OAuth token fetch and game search
- Seeds import real games from IGDB with cover images
- `games/index.html.erb` — hero section and card grid with cover images
- `games/show.html.erb` shows game detail, patches, follow/unfollow button, and upcoming events
- Game model has all associations: patches, events, favourites

### Person 3 — Hortense — Patches + Summaries + Styling ✅

- `Patch` model has `belongs_to :game` and `has_many :patch_summaries`
- `PatchSummary` model has `belongs_to :patch`
- `PatchesController` with index (scoped to game) and show (includes summaries)
- `patches/show.html.erb` displays patch notes and AI summary cards with Generate Summary button
- `patches/index.html.erb` lists patches for a game
- Routes set up with nested patches under games
- Navbar rebuilt — GameBrief brand, real links, clean dropdown
- Games index fully styled with card grid and cover images
- Events show page styled with badges and calendar button

### Person 4 — Baptiste — Events + Favourites + Reminders + AI ✅

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

## Round 2 Tasks — ✅ Complete

All Round 2 tasks finished. See completed work above for details.

---

## Round 3 Tasks — In Progress

### Person 1 — Bianca — Heroku + Demo Prep

**Branch:** `feature/demo-prep`

| # | Task | Done? |
|---|------|-------|
| 1 | Add Heroku redirect URI to Google Cloud Console: `https://gamebrief-d7b349ea445b.herokuapp.com/users/auth/google_oauth2/callback` | ⬜ |
| 2 | Test Google login works on the live Heroku URL | ⬜ |
| 3 | After each teammate merges, run `heroku run rails db:seed` | ⬜ |
| 4 | Full demo walkthrough on Heroku: login → games → patch → summary → follow → event → reminder → dashboard | ⬜ |
| 5 | Note and report any crashes to the team | ⬜ |

---

### Person 2 — Hortense — Styling Round 2

**Branch:** `feature/styling-2`

| # | Task | Done? |
|---|------|-------|
| 1 | Add Dashboard link to the navbar | ⬜ |
| 2 | Style `patches/show.html.erb` — patch notes block, summary card | ⬜ |
| 3 | Style `dashboard.html.erb` — game cards matching the games index | ⬜ |
| 4 | Clean up duplicate Google Calendar section in `events/show.html.erb` (remove lines 27–46) | ⬜ |
| 5 | Style the Devise login/signup pages | ⬜ |

---

### Person 3 — Baptiste — Fix + Polish AI Summaries

**Branch:** `feature/ai-summaries-polish`

| # | Task | Done? |
|---|------|-------|
| 1 | **Fix:** Remove `thinking: { type: "adaptive" }` from `SummaryService` — will cause API error | ⬜ |
| 2 | Only show "Generate Summary" button if no summary exists yet | ⬜ |
| 3 | Add flash message after generating: `"Summary generated!"` | ⬜ |
| 4 | Wrap API call in `begin/rescue` — redirect with error flash if it fails | ⬜ |
| 5 | Test end-to-end: click button, summary appears | ⬜ |

---

### Person 4 — Baptiste — Dashboard Polish

**Branch:** `feature/dashboard-polish`

| # | Task | Done? |
|---|------|-------|
| 1 | Show cover images on dashboard game cards (not just text links) | ⬜ |
| 2 | Show latest patch title under each game card | ⬜ |
| 3 | Add upcoming events section — load events from user's reminders | ⬜ |
| 4 | Add friendly empty state if no games followed | ⬜ |

---

## Demo Flow (End Goal)

The app should demonstrate this flow without errors:

1. User visits the site and is redirected to login
2. User logs in with Google
3. Games index loads with cover images
4. User clicks a game and sees the game detail page
5. User clicks Follow on the game
6. User clicks a patch and sees the patch notes + AI summary
7. User clicks an event and sets a reminder
8. User visits the dashboard and sees their followed games

---

*Last updated: Round 2 complete, Round 3 in progress*
