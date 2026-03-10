# GameBrief — Team Tasks

---

## Round 4 — One Task Remaining

### Person 2 — Hortense — Mobile Check

**Branch:** `feature/mobile-polish`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Go through each page on a small screen — write down anything that looks broken and report to Ed | ⬜ |

---

## Round 5 — Polish + Additional Features

> Ed's tasks 1–6 are done and logged in [GameBrief_Team_Progress.md](GameBrief_Team_Progress.md).

### Person 1 — Ed — Final Navbar Check

**Branch:** `feature/games-index-polish`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Do a final pass — check every link in the navbar works and no broken routes exist | ⬜ |

---

### Person 2 — Hortense — Styling Fixes

**Branch:** `feature/styling-fixes`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Style the Devise login and signup pages so they match the dark theme | ⬜ |
| 2 | Add `<meta>` description tag to `application.html.erb` | ⬜ |
| 3 | Check all pages have a page title set using `content_for :title` — add any that are missing | ⬜ |
| 4 | Fix any mobile layout issues found in the Round 4 mobile check | ⬜ |

---

### Person 3 — Baptiste — Patch + Summary Polish

**Branch:** `feature/patch-polish`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add a loading/disabled state to the Generate Summary button so it can't be double-clicked | ⬜ |
| 2 | Order patches by most recent first on the game show page (`@game.patches.order(created_at: :desc)`) | ⬜ |
| 3 | Add a flash message after generating a summary: `"Summary generated!"` | ⬜ |
| 4 | Wrap the Claude API call in `begin/rescue` — redirect with an error flash if it fails | ⬜ |

---

### Person 4 — Bianca — Dedicated Profile Page

**Branch:** `feature/profile-page`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Create a `profile` route and action in `PagesController` | ⬜ |
| 2 | Create `app/views/pages/profile.html.erb` — show the user's email, join date, followed game count, and reminder count | ⬜ |
| 3 | Add a "Profile" link to the navbar dropdown | ⬜ |
| 4 | Show the latest patch title under each game card on the My Profile page | ⬜ |

---

## Round 6 — Planned Features (Group of 4)

> These are the next four parallel tasks for the team of 4. Start once Round 5 is fully merged and working on Heroku, and continue to prioritise bug fixes where needed.

---

### Task 1 — Activity Feed on My Profile

> Suggested: Baptiste
>
> Reason: Baptiste already built My Profile, My Game's Patches, reminders, and the chatbot flow, so this fits his existing ownership of profile logic and patch-related UI.

**Branch:** `feature/activity-feed`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | On the My Profile page, add a "Recent Updates" section below followed games | ⬜ |
| 2 | Load the 5 most recent patches from games the user follows | ⬜ |
| 3 | Show each patch as a small card: game name, patch title, date, link to patch | ⬜ |

---

### Task 2 — "New" Badge on Recent Patches

> Suggested: Hortense
>
> Reason: Hortense has already owned most patch page styling and UI polish, so this is a good continuation of her patch presentation and frontend work.

**Branch:** `feature/new-badge`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add a `published_at` datetime column to the `patches` table | ⬜ |
| 2 | Update the seeds to set `published_at` to realistic recent dates | ⬜ |
| 3 | Show a green "NEW" badge on patch cards where `published_at` is within the last 7 days | ⬜ |

---

### Task 3 — Web Scraping — Auto-Import Patch Notes

> Suggested: Ed
>
> Reason: Ed has already handled IGDB integration, Twitch OAuth, Heroku checks, and service-layer setup, so scraper infrastructure is the closest match to his previous work.

**Branch:** `feature/scraper`

Patches are currently entered manually. A scraper would pull real patch notes from official game sites automatically.

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add `source_url` string column to the `patches` table so scraped records can be deduplicated | ⬜ |
| 2 | Add `nokogiri` and `httparty` gems to the Gemfile | ⬜ |
| 3 | Create `app/services/scrapers/base_scraper.rb` with a shared `call` interface | ⬜ |
| 4 | Build one scraper as a proof of concept — e.g. `scrapers/fortnite_scraper.rb` — fetches and parses the patch note list page and returns an array of `{ title:, content:, source_url: }` hashes | ⬜ |
| 5 | Create a rake task `rails patches:scrape` that runs each scraper and upserts results into the `patches` table | ⬜ |
| 6 | Add Heroku Scheduler (free add-on) and configure it to run `rails patches:scrape` daily | ⬜ |

---

### Task 4 — Events Page Layout: In-Game Main + IRL Side Section

> Suggested: Bianca
>
> Reason: Bianca has already worked on the events index, dashboard reminders, and card-based event displays, so this is a natural continuation of her events page ownership.

**Branch:** `feature/events-layout`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Add an `event_type` column to events: `in_game` or `irl` | ⬜ |
| 2 | Update seeds to set `event_type` on all existing events | ⬜ |
| 3 | Update `events/index.html.erb` so the main section of the page shows **in-game events** as the primary content area | ⬜ |
| 4 | Add a smaller side section that lists **IRL events** separately | ⬜ |
| 5 | Make the layout visually clear that most events are in-game, with IRL events treated as secondary content | ⬜ |

---

## Round 7 — Planned Features (Next Group of 4)

> These are the next planned features after Round 6. Two strong ownership suggestions are already clear; the final two task slots can either be added later or pulled forward from new bugs / polish work once Round 6 is complete.

---

### Task 1 — Email Confirmation for Reminders

> Suggested: Baptiste
>
> Reason: Baptiste built reminders, events, and the related controller flow already, so mailer confirmation is the cleanest follow-on task for him.

**Branch:** `feature/reminder-email`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Create a `ReminderMailer` using `rails g mailer ReminderMailer` | ⬜ |
| 2 | Add a `confirmation` method that sends the event name, date, and a link to the event page | ⬜ |
| 3 | Call `ReminderMailer.confirmation(reminder).deliver_later` inside `RemindersController#create` | ⬜ |
| 4 | Configure ActionMailer for development using the `letter_opener` gem so emails open in the browser | ⬜ |

---

### Task 2 — Live Streamers on Game Page

> Suggested: Ed
>
> Reason: Ed already owns the external API side of the app through IGDB/Twitch work, so another Twitch-backed integration should stay with him.

**Branch:** `feature/live-streamers`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Use the existing Twitch credentials to call `GET https://api.twitch.tv/helix/streams?game_id=...` | ⬜ |
| 2 | Map the IGDB game to a Twitch game ID (IGDB and Twitch share the same game IDs) | ⬜ |
| 3 | Add a `TwitchStreamsService` that fetches the top 6 live streams for a given game | ⬜ |
| 4 | Add a "Watch Live" section to `games/show.html.erb` showing streamer cards: avatar, name, title, viewer count, link | ⬜ |
| 5 | Hide the section if no streams are live | ⬜ |

---

### Task 3 — Reserved for next agreed feature / bugfix batch

> Suggested: Hortense
>
> Reason: Hortense has consistently owned cross-page styling, mobile checks, and visual polish, so this slot is a good placeholder for the next UI / responsiveness task that comes out of testing.

**Branch:** `feature/tbd-hortense`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Hold for next agreed styling / UX / mobile polish task after Round 6 | ⬜ |

---

### Task 4 — Reserved for next agreed feature / bugfix batch

> Suggested: Bianca
>
> Reason: Bianca has repeatedly owned dashboard, profile, and events UI work, so this slot is a good placeholder for the next page-level feature that extends those areas.

**Branch:** `feature/tbd-bianca`

| # | Task | Done? |
| --- | ------ | ------- |
| 1 | Hold for next agreed dashboard / profile / events feature after Round 6 | ⬜ |

---

## Demo Flow (End Goal)

The app should demonstrate this flow without errors:

1. User visits the home page
2. User logs in with Google (or demo account)
3. Games index loads with cover images, search, genre filters, sort
4. User clicks a game and sees the game detail page
5. User clicks Follow on the game
6. User clicks a patch, sees the patch notes + 3 AI summary types, and asks the chatbot a question
7. User clicks an event, reads the AI summary, and sets a reminder
8. User visits My Profile and sees their followed games, recent patches, and upcoming reminders

---

Last updated: Round 3 ✅ | Round 4 ✅ (Hortense mobile check ⬜) | Round 5 Ed ✅ tasks 1–6 | Round 5 others ⬜ | Round 6 planned work pending
