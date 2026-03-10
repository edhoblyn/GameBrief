# GameBrief — Team Tasks

---

## Round 3 — Bug Fixes + Page Polish ✅

> Completed. See [GameBrief_Team_Progress.md](GameBrief_Team_Progress.md) for details.

---

## Round 4 — New Features

> Estimated effort: 2 days for all 4 people working in parallel

### Person 1 — Ed — Search + Heroku Checks ✅

> Completed. See [GameBrief_Team_Progress.md](GameBrief_Team_Progress.md) for details.

---

### Person 2 — Hortense — Error Pages + Mobile Check

**Branch:** `feature/mobile-polish`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Create `app/views/errors/404.html.erb` — a friendly "page not found" page with a link back home | ✅ |
| 2 | Create `app/views/errors/500.html.erb` — a friendly "something went wrong" page with a link back home | ✅ |
| 3 | Go through each page on a small screen — write down anything that looks broken and report to Ed | ⬜ |

> **Moved to Baptiste:** Loading state on Generate Summary button (task 4 below)
> **Moved to Ed:** Final styling pass (task 5 below)

---

### Person 3 — Baptiste — Multiple Summary Types ✅

> Completed. See [GameBrief_Team_Progress.md](GameBrief_Team_Progress.md) for details.

---

### Person 4 — Bianca — Events Index + Reminders List ✅

> Completed. See [GameBrief_Team_Progress.md](GameBrief_Team_Progress.md) for details.

---

## Round 5 — Polish + Extra Features

> Estimated effort: 2 days for all 4 people working in parallel

---

### Person 1 — Ed — Games Index Polish + Finishing Touches

**Branch:** `feature/games-index-polish`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add a `genre` string column to the `games` table: `rails g migration AddGenreToGames genre:string` | ⬜ |
| 2 | Update seeds to set a genre on each game — e.g. `"FPS"`, `"Battle Royale"`, `"Sports"`, `"Sandbox"`, `"Mobile"` | ⬜ |
| 3 | Add genre filter buttons above the games grid — filter via `params[:genre]` in `GamesController#index` | ⬜ |
| 4 | Add sort options to the games index — alphabetical (A–Z) and most-followed | ⬜ |
| 5 | Add a simple footer to `application.html.erb` — GameBrief name, current year, team names | ⬜ |
| 6 | Add `loading="lazy"` to all cover images so pages load faster | ⬜ |
| 7 | Do a final pass — check every link in the navbar works and no broken routes exist | ⬜ |

---

### Person 2 — Hortense — Styling Fixes

**Branch:** `feature/styling-fixes`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Style the Devise login and signup pages so they match the dark theme | ⬜ |
| 2 | Add `<meta>` description tag to `application.html.erb` | ⬜ |
| 3 | Check all pages have a page title set using `content_for :title` — add any that are missing | ⬜ |
| 4 | Fix any mobile layout issues found in Round 4 mobile check | ⬜ |

---

### Person 3 — Baptiste — Patch + Summary Improvements

**Branch:** `feature/patch-polish`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add a loading/disabled state to the Generate Summary button so it can't be double-clicked | ⬜ |
| 2 | Order patches by most recent first on the game show page (`@game.patches.order(created_at: :desc)`) | ⬜ |
| 3 | If all 3 summary types already exist for a patch, hide all generate buttons and show "Summaries up to date" | ⬜ |
| 4 | Add a flash message after generating a summary: `"Summary generated!"` | ⬜ |
| 5 | Wrap the Claude API call in `begin/rescue` — redirect with error flash if it fails | ⬜ |

---

### Person 4 — Bianca — Profile Page + Dashboard

**Branch:** `feature/profile-page`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Create a `profile` route and action in `PagesController` | ⬜ |
| 2 | Create `app/views/pages/profile.html.erb` — show the user's email, join date, followed game count and reminder count | ⬜ |
| 3 | Add a "Profile" link to the navbar (next to Dashboard) | ⬜ |
| 4 | Show latest patch title under each game card on the dashboard | ⬜ |
| 5 | Add a friendly empty state message if the user has no followed games on the dashboard | ⬜ |

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

## Round 7 — Team Feature Requests

> These are features the team has requested. Tasks are unassigned — pick based on interest and what you built before.

---

### Task person A — Rename Dashboard → My Profile + Sidebar

> Suggested: whoever built the dashboard — Baptiste + Bianca

**Branch:** `feature/my-profile`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Rename "Dashboard" to "My Profile" — update the navbar link, route name, page title, and any internal links | ⬜ |
| 2 | Add a "My Game's Patches" section to the My Profile page showing recent patches from followed games | ⬜ |
| 3 | Build a sidebar for the My Profile page: My Games, My Patches, My Events, Communities, My Recommendations | ⬜ |
| 4 | Hide the top navbar on the My Profile page — the sidebar replaces it for navigation | ⬜ |

---

### Task person B — Patches Navbar Link + Dedicated Patches Page

> Suggested: whoever built patches — Hortense + Baptiste

**Branch:** `feature/patches-index`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add a "Patches" link to the main navbar | ⬜ |
| 2 | Create a dedicated `patches/index` page (not scoped to a single game) showing all recent patches | ⬜ |
| 3 | Add three sections to the patches index: "From Games I Follow", "Recommended", "All Patches" | ⬜ |
| 4 | Add the AI chatbot panel to `patches/show.html.erb` — collapsible, uses patch content as context, answers via Claude | ⬜ |

---

### Task person C — Events Page: Filters + Personalised Sections

> Suggested: whoever built events — Baptiste + Bianca

**Branch:** `feature/events-revamp`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add an `event_type` column to events: `in_game` or `irl` | ⬜ |
| 2 | Update seeds to set `event_type` on all existing events | ⬜ |
| 3 | Add a filter bar to `events/index.html.erb` with three sets of filters (see below) | ⬜ |
| 4 | **Filter 1 — Event type:** "All" / "In-Game" / "IRL" — via `params[:event_type]` in `EventsController#index` | ⬜ |
| 5 | **Filter 2 — Game:** a dropdown of all games — via `params[:game_id]` in `EventsController#index` | ⬜ |
| 6 | **Filter 3 — Time period:** "All" / "This Week" / "This Month" / "Future" — filter on `start_date` | ⬜ |
| 7 | Filters should work together — applying multiple filters narrows results (AND logic) | ⬜ |
| 8 | Add three sections to the events index: "From Games I Follow", "Recommended", "All Events" | ⬜ |

---

### Task person D — Live Streamers on Game Page

> Suggested: whoever built the IGDB/Twitch integration — Ed

**Branch:** `feature/live-streamers`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Use the existing Twitch credentials to call `GET https://api.twitch.tv/helix/streams?game_id=...` | ⬜ |
| 2 | Map the IGDB game to a Twitch game ID (IGDB and Twitch share the same game IDs) | ⬜ |
| 3 | Add a `TwitchStreamsService` that fetches the top 6 live streams for a given game | ⬜ |
| 4 | Add a "Watch Live" section to `games/show.html.erb` showing streamer cards: avatar, name, title, viewer count, link | ⬜ |
| 5 | Hide the section if no streams are live | ⬜ |

---

## Demo Flow (End Goal)

The app should demonstrate this flow without errors:

1. User visits the home page
2. User logs in with Google (or demo account)
3. Games index loads with cover images
4. User clicks a game and sees the game detail page with live streamers
5. User clicks Follow on the game
6. User clicks a patch, sees the patch notes + AI summary, and asks the chatbot a question
7. User clicks an event and sets a reminder
8. User visits My Profile and sees their followed games, patches, and upcoming events

---

Last updated: Round 3 ✅ | Round 4 partial — Baptiste ✅, Bianca ✅, Ed ✅, Hortense ⬜ (mobile check only) | Round 5 assigned by person | Rounds 6–7 pending
