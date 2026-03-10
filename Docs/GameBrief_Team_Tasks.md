# GameBrief — Team Tasks

---

## Round 3 — Bug Fixes + Page Polish

> Estimated effort: 1 day for all 4 people working in parallel

### Person 1 — Ed — Heroku + Demo Prep

**Branch:** `feature/demo-prep`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add Heroku redirect URI to Google Cloud Console: `https://gamebrief-d7b349ea445b.herokuapp.com/users/auth/google_oauth2/callback` | ✅ |
| 2 | Test Google login works on the live Heroku URL | ✅ |
| 3 | After each teammate merges, run `heroku run rails db:seed` | ✅ |
| 4 | Full demo walkthrough on Heroku: login → games → patch → summary → follow → event → reminder → dashboard | ✅ |
| 5 | Note and report any crashes to the team | ✅ |

---

### Person 2 — Hortense — Styling Round 2

**Branch:** `feature/styling-2`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add Dashboard link to the navbar | ✅ |
| 2 | Style `patches/show.html.erb` — patch notes block, summary card | ✅ |
| 3 | Style `dashboard.html.erb` — game cards matching the games index | ✅ |
| 4 | Clean up duplicate Google Calendar section in `events/show.html.erb` (remove lines 27–46) | ⬜ |
| 5 | Style the Devise login/signup pages | ⬜ |

---

### Person 3 — Baptiste — Fix + Polish AI Summaries

**Branch:** `feature/ai-summaries-polish`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | **Fix:** Remove `thinking: { type: "adaptive" }` from `SummaryService` — will cause API error | ✅ |
| 2 | Only show "Generate Summary" button if no summary exists yet | ✅ |
| 3 | Add flash message after generating: `"Summary generated!"` | ⬜ |
| 4 | Wrap API call in `begin/rescue` — redirect with error flash if it fails | ⬜ |
| 5 | Test end-to-end: click button, summary appears | ⬜ |

---

### Person 4 — Bianca — Dashboard Polish

**Branch:** `feature/dashboard-polish`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Show cover images on dashboard game cards (not just text links) | ✅ |
| 2 | Show latest patch title under each game card | ⬜ |
| 3 | Add upcoming events section — load events from user's reminders | ✅ |
| 4 | Add friendly empty state if no games followed | ⬜ |

---

## Round 4 — New Features

> Estimated effort: 2 days for all 4 people working in parallel

### Person 1 — Ed — Search + Heroku Checks

**Branch:** `feature/search`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add a search bar to `games/index.html.erb` that filters games by name | ⬜ |
| 2 | Add a `search` action or filter to `GamesController#index` using `params[:query]` | ⬜ |
| 3 | Run full demo walkthrough on Heroku and note any broken pages | ⬜ |
| 4 | Confirm `heroku run rails db:seed` produces clean data with all 12 games | ⬜ |
| 5 | Make sure the demo user (`demo@test.com` / `123456`) works on Heroku as a backup if Google login fails | ⬜ |

---

### Person 2 — Hortense — Mobile + Error Pages

**Branch:** `feature/mobile-polish`

| # | Task | Done? |
| --- | ------ | ------- |
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
| --- | ------ | ------- |
| 1 | Add a `summary_type` column to `patch_summaries` table: `rails g migration AddSummaryTypeToPatchSummaries summary_type:string` | ⬜ |
| 2 | Update `SummaryService` to accept a `summary_type` argument and adjust the Claude prompt accordingly | ⬜ |
| 3 | Add 3 generate buttons to `patches/show.html.erb`: "Quick Summary", "Casual Impact", "Should I Log In?" | ⬜ |
| 4 | Display each summary type in its own labelled card on the patch show page | ⬜ |
| 5 | Update seeds to include all 3 summary types for each patch | ⬜ |

---

### Person 4 — Bianca — Events Index + Reminders List

**Branch:** `feature/events-polish`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Style `events/index.html.erb` — card layout showing game name, event title and date | ⬜ |
| 2 | Add a "My Reminders" section to the dashboard showing events the user has set reminders for | ⬜ |
| 3 | Add an "Upcoming Events" section to `games/show.html.erb` that links through to the event page | ⬜ |
| 4 | Add a count badge to the dashboard — e.g. "3 followed games" and "2 upcoming reminders" | ⬜ |

---

## Round 5 — Polish + Extra Features

> Estimated effort: 2 days for all 4 people working in parallel

Tasks are unassigned. Suggestions are based on who worked on related features.

---

### Task Group A — User Profile Page

> Suggested: whoever built the dashboard — Baptiste built it, Bianca polished it

**Branch:** `feature/profile-page`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Create a `profile` route and action in `PagesController` | ⬜ |
| 2 | Create `app/views/pages/profile.html.erb` — show the user's email and join date | ⬜ |
| 3 | Add a stat summary: number of followed games, number of reminders set | ⬜ |
| 4 | Add a "Profile" link to the navbar dropdown | ⬜ |
| 5 | Add a "Delete account" link using Devise's `registrations#destroy` | ⬜ |

---

### Task Group B — Games Index Improvements

> Suggested: whoever built the games index and search — Ed

**Branch:** `feature/games-index-polish`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add sort options to the games index — alphabetical (A–Z) and most-followed | ⬜ |
| 2 | Show a follower count badge on each game card (e.g. "142 following") | ⬜ |
| 3 | Highlight games the current user already follows with a different card style | ⬜ |
| 4 | Add a "Popular Games" section at the top of the index showing the 3 most-followed games | ⬜ |

---

### Task Group C — Patch + Summary Improvements

> Suggested: whoever worked on patches/show and AI summaries — Hortense + Baptiste

**Branch:** `feature/patch-polish`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Show patch publish date on `patches/show.html.erb` and `patches/index.html.erb` | ⬜ |
| 2 | Order patches by most recent first on the game show page | ⬜ |
| 3 | Add a "Back to game" breadcrumb link on the patch show page | ⬜ |
| 4 | Add a thumbs up / thumbs down reaction to each AI summary card (no backend needed — just UI) | ⬜ |
| 5 | If all 3 summary types already exist, hide all generate buttons and show a "Summaries up to date" message | ⬜ |

---

### Task Group D — App-Wide Finishing Touches

> Suggested: whoever handled styling and error pages — Hortense

**Branch:** `feature/final-touches`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add a simple footer to `application.html.erb` — GameBrief name, current year, team names | ⬜ |
| 2 | Add `<meta>` description tags to the layout for basic SEO | ⬜ |
| 3 | Add `loading="lazy"` to all cover images so pages load faster | ⬜ |
| 4 | Check all pages have a page title set using `content_for :title` | ⬜ |
| 5 | Do a final pass — check every link in the navbar works and no broken routes exist | ⬜ |

---

## Round 6 — Ambitious Extras (if time allows)

> Only attempt once Rounds 3–5 are fully merged and working on Heroku. Prioritise fixing bugs over these. Tasks are independent — pick whichever sounds most interesting. Each stretch task is roughly half a day's work.

---

### Stretch Task 1 — Activity Feed on Dashboard

> Suggested: whoever built the dashboard and events — Baptiste + Bianca

**Branch:** `feature/activity-feed`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | On the dashboard, add a "Recent Updates" section below followed games | ⬜ |
| 2 | Load the 5 most recent patches from games the user follows | ⬜ |
| 3 | Show each patch as a small card: game name, patch title, date, link to patch | ⬜ |

---

### Stretch Task 2 — "New" Badge on Recent Patches

> Suggested: whoever styled the games and patches pages — Hortense

**Branch:** `feature/new-badge`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add a `published_at` datetime column to the `patches` table | ⬜ |
| 2 | Update the seeds to set `published_at` to realistic recent dates | ⬜ |
| 3 | Show a green "NEW" badge on patch cards where `published_at` is within the last 7 days | ⬜ |

---

### Stretch Task 3 — AI One-Line Event Summary

> Suggested: whoever built the AI summary service — Baptiste

**Branch:** `feature/event-summary`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add a `summary` column to the `events` table | ⬜ |
| 2 | Create an `EventSummaryService` that sends the event title + description to Claude and returns a single sentence | ⬜ |
| 3 | Add a "Summarise Event" button to `events/show.html.erb` that generates and saves the summary | ⬜ |
| 4 | Display the summary at the top of the event page when it exists | ⬜ |

---

### Stretch Task 4 — Web Scraping — Auto-Import Patch Notes

> Suggested: whoever built the IGDB service and seed data — Ed

**Branch:** `feature/scraper`

Patches are currently entered manually. A scraper would pull real patch notes from official game sites automatically.

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add `source_url` string column to the `patches` table so scraped records can be deduplicated | ⬜ |
| 2 | Add `nokogiri` and `httparty` gems to the Gemfile | ⬜ |
| 3 | Create `app/services/scrapers/base_scraper.rb` with a shared `call` interface | ⬜ |
| 4 | Build one scraper as a proof of concept — e.g. `scrapers/fortnite_scraper.rb` — that fetches and parses the patch note list page and returns an array of `{ title:, content:, source_url: }` hashes | ⬜ |
| 5 | Create a rake task `rails patches:scrape` that runs each scraper and upserts results into the `patches` table | ⬜ |
| 6 | Add Heroku Scheduler (free add-on) and configure it to run `rails patches:scrape` daily | ⬜ |

---

### Stretch Task 5 — Email Confirmation for Reminders

> Suggested: whoever built the reminders — Baptiste

**Branch:** `feature/reminder-email`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Create a `ReminderMailer` using `rails g mailer ReminderMailer` | ⬜ |
| 2 | Add a `confirmation` method that sends the event name, date, and a link to the event page | ⬜ |
| 3 | Call `ReminderMailer.confirmation(reminder).deliver_later` inside `RemindersController#create` | ⬜ |
| 4 | Configure ActionMailer for development using the `letter_opener` gem so emails open in the browser | ⬜ |

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

Last updated: Day 2 — Round 3 mostly done, Round 4 not yet started
