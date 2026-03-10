# GameBrief — Team Tasks

---

## Round 3 Tasks — In Progress

### Person 1 — Ed — Heroku + Demo Prep

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

### Person 4 — Bianca — Dashboard Polish

**Branch:** `feature/dashboard-polish`

| # | Task | Done? |
|---|------|-------|
| 1 | Show cover images on dashboard game cards (not just text links) | ⬜ |
| 2 | Show latest patch title under each game card | ⬜ |
| 3 | Add upcoming events section — load events from user's reminders | ⬜ |
| 4 | Add friendly empty state if no games followed | ⬜ |

---

## Round 4 Tasks — Demo Ready

### Person 1 — Ed — Final Heroku Checks + Search

**Branch:** `feature/search`

| # | Task | Done? |
|---|------|-------|
| 1 | Add a search bar to `games/index.html.erb` that filters games by name | ⬜ |
| 2 | Add a `search` action or filter to `GamesController#index` using `params[:query]` | ⬜ |
| 3 | Run full demo walkthrough on Heroku and note any broken pages | ⬜ |
| 4 | Confirm `heroku run rails db:seed` produces clean data with all 12 games | ⬜ |
| 5 | Make sure the demo user (`demo@test.com` / `123456`) works on Heroku as a backup if Google login fails during the presentation | ⬜ |

---

### Person 2 — Hortense — Mobile + Error Pages

**Branch:** `feature/mobile-polish`

| # | Task | Done? |
|---|------|-------|
| 1 | Check every page on a mobile screen size — fix any broken layouts | ⬜ |
| 2 | Create `app/views/errors/404.html.erb` — a friendly "page not found" page | ⬜ |
| 3 | Create `app/views/errors/500.html.erb` — a friendly "something went wrong" page | ⬜ |
| 4 | Add a loading/disabled state to the Generate Summary button so it can't be double-clicked | ⬜ |
| 5 | Final styling pass — check fonts, spacing and colours are consistent across all pages | ⬜ |

---

### Person 3 — Baptiste — Multiple Summary Types

**Branch:** `feature/summary-types`

The original spec calls for 3 summary types per patch: Quick Summary, Casual Impact, and Should I Log In.

| # | Task | Done? |
|---|------|-------|
| 1 | Add a `summary_type` column to `patch_summaries` table: `rails g migration AddSummaryTypeToPatchSummaries summary_type:string` | ⬜ |
| 2 | Update `SummaryService` to accept a `summary_type` argument and adjust the Claude prompt accordingly | ⬜ |
| 3 | Add 3 generate buttons to `patches/show.html.erb`: "Quick Summary", "Casual Impact", "Should I Log In?" | ⬜ |
| 4 | Display each summary type in its own labelled card on the patch show page | ⬜ |
| 5 | Update seeds to include all 3 summary types for each patch | ⬜ |

---

### Person 4 — Bianca — Events Index + Reminders List

**Branch:** `feature/events-polish`

| # | Task | Done? |
|---|------|-------|
| 1 | Style `events/index.html.erb` — card layout showing game name, event title and date | ⬜ |
| 2 | Add a "My Reminders" section to the dashboard showing events the user has set reminders for | ⬜ |
| 3 | Add an "Upcoming Events" section to `games/show.html.erb` that links through to the event page | ⬜ |
| 4 | Add a count badge to the dashboard — e.g. "3 followed games" and "2 upcoming reminders" | ⬜ |

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

Last updated: Round 3 and Round 4 in progress
