# GameBrief — Team Tasks

> Last updated: 2026-03-11 | Focus: Progress updated after today's scraping, profile, and bug-fix session

---

## Today's Split

| Person | Focus |
| --- | --- |
| Ed | Web scraping (auto-import patch notes) |
| Hortense | Bug fixes — public access + styling |
| Baptiste | Bug fixes — patch/summary issues |
| Bianca | Bug fixes — profile page + navbar |

---

## Ed — Web Scraping (Marvel Rivals)

**Branch:** `feature/scraper`

Patches are currently entered manually. This task builds a scraper to auto-import real patch notes from **Marvel Rivals** as a proof of concept. Their patch notes page is fully server-side rendered — no headless browser needed.

**Target site:** `https://www.marvelrivals.com/gameupdate/`

| # | Task | Done? |
| --- | --- | --- |
| 1 | Add `source_url` string column to `patches` table: `rails g migration AddSourceUrlToPatches source_url:string` then `rails db:migrate` | ✅ |
| 2 | Add `nokogiri` gem to the Gemfile (httparty is optional — `open-uri` works fine), then run `bundle install` | ✅ |
| 3 | Add Marvel Rivals to the seed data (or `rails console`) so there's a `Game` record to attach patches to: `Game.create!(name: "Marvel Rivals", slug: "marvel-rivals", genre: "shooter")` | ✅ |
| 4 | Create `app/services/scrapers/marvel_rivals_scraper.rb`. It should: fetch the index page (`https://www.marvelrivals.com/gameupdate/`), find all `a.list-item` elements, follow each link, then on the detail page extract `h1.artTitle` (title), `p.date` (date), and `div.artText` (full content). Return an array of `{ title:, content:, source_url: }` hashes. Set a browser-like `User-Agent` header to avoid being blocked. | ✅ |
| 5 | Create a rake task `lib/tasks/patches.rake` with `rails patches:scrape_marvel_rivals`. It should call the scraper, then for each result call `Patch.find_or_initialize_by(source_url:)` and update `title` and `content` — this prevents duplicates on re-runs | ✅ |
| 6 | Add a recurring job so Marvel Rivals patch scraping runs automatically every week in production | ✅ |
| 7 | Test it locally: run `rails patches:scrape_marvel_rivals` and confirm patch records appear in the DB attached to the Marvel Rivals game | ✅ |

**Follow-up for later:** add admin-only controls to trigger a manual scrape on demand and show the last successful scrape time/status.

**Today's progress:** the Marvel Rivals proof of concept was expanded into the shared `PatchScrapeRunner` pipeline, production scheduling was documented around `bin/rake patches:scrape_all`, scrape failures were isolated so one broken source does not stop the full run, seeds were updated to preserve scraped data, and scraped patches are now shown before placeholders on game pages.

## Ed — Web Scraping Follow-up (Blocked Sources)

**Branch:** `feature/scraper`

Some previously working patch-note sources are now blocked or unreliable with the current HTML scraping approach. This follow-up replaces brittle scraping with official APIs or more stable structured sources where possible.

| # | Task | Done? |
| --- | --- | --- |
| 1 | Replace the `Minecraft` HTML scraper with the official Zendesk Help Center API for section `360001186971` so patch articles can be imported without depending on the rendered changelog page | ⬜ |
| 2 | Replace the `Helldivers 2` HTML scraper with the official Zendesk Help Center API for section `12541983411100` so patch articles can be imported without depending on the rendered support page | ⬜ |
| 3 | Replace the `Destiny 2` HTML scraper with Bungie's official content/news API and import real patch-note articles through a stable official endpoint | ⬜ |
| 4 | Investigate a production-safe official source for `Fortnite` patch notes. Prefer Epic documentation or another structured official release-notes source instead of `fortnite.com/news`, which is blocked to the current scraper | ⬜ |
| 5 | Add `published_at` to `Patch` and update importers so the app can reliably enforce the "last 6 months" requirement across all supported games | ⬜ |
| 6 | Update the affected scraper/importer tests to cover API payload parsing, date filtering, and duplicate prevention for the new source strategy | ⬜ |
| 7 | Update the scraping guide to document which games use APIs vs HTML scraping, which sources are currently blocked, and the current known limitations | ✅ |

**Today's progress:** scraper coverage was extended to Warzone, Fortnite, Apex Legends, EA Sports FC 26, Helldivers 2, Destiny 2, Minecraft, Valorant, Roblox, Clash Royale, and Clash of Clans. The guide now documents the current source strategy, Heroku scheduling path, and known blockers for Fortnite and Destiny 2, but the API migrations and `published_at` work are still open.

**Key HTML selectors on the detail page:**

| What | Selector |
| --- | --- |
| All patch links (index) | `a.list-item` → `href` |
| Patch title (detail) | `h1.artTitle` |
| Date (detail) | `p.date` (format: `2026/03/04`) |
| Full content (detail) | `div.artText` |

---

## Hortense — Bug Fixes: Public Access + Styling

**Branch:** `bugfix/public-access-and-styling`

| # | Bug / Task | File(s) | Done? |
| --- | --- | --- | --- |
| 1 | **Games index requires login** — `ApplicationController` has global `authenticate_user!`. `GamesController` needs `skip_before_action :authenticate_user!, only: [:index, :show]` so guests can browse games | `app/controllers/games_controller.rb` | ⬜ |
| 2 | **Devise mailer placeholder** — Change `config.mailer_sender` from `'please-change-me...'` to `'noreply@gamebrief.com'` | `config/initializers/devise.rb` | ⬜ |
| 3 | **Style Devise login and signup pages** — Add Bootstrap card wrapper and dark theme to match the rest of the app | `app/views/devise/sessions/new.html.erb`, `registrations/new.html.erb` | ⬜ |
| 4 | **Add `<meta>` description tag** to the application layout | `app/views/layouts/application.html.erb` | ⬜ |
| 5 | **Check page titles** — Make sure every page sets a title using `content_for :title`. Add any that are missing | All views | ⬜ |

---

## Baptiste — Bug Fixes: Patches + Summaries

**Branch:** `bugfix/patches-and-summaries`

| # | Bug / Task | File(s) | Done? |
| --- | --- | --- | --- |
| 1 | **SQL injection risk** — `PatchesController#index` builds a raw SQL string using `followed_game_ids.join(',')`. Replace with a safe ActiveRecord query (e.g. `where(game_id: followed_game_ids)`) | `app/controllers/patches_controller.rb` | ⬜ |
| 2 | **SQL injection risk** — Same issue in `EventsController#index`. Apply the same fix | `app/controllers/events_controller.rb` | ⬜ |
| 3 | **Add loading state to Generate Summary button** — Disable the button on click with `data-disable-with="Generating..."` so it can't be double-submitted | Patch and event show views | ⬜ |
| 4 | **Wrap Claude API call in begin/rescue** — If `SummaryService` or `EventSummaryService` raises an error, catch it and redirect back with a flash error message instead of crashing | `app/services/summary_service.rb`, `app/services/event_summary_service.rb` | ⬜ |
| 5 | **Order patches by most recent first** on the game show page — change to `@game.patches.order(created_at: :desc)` | `app/controllers/games_controller.rb` or game show view | ⬜ |
| 6 | **Add flash message after generating a summary** — Show `"Summary generated!"` on success | `app/controllers/patches_controller.rb`, `app/controllers/events_controller.rb` | ⬜ |

---

## Bianca — Bug Fixes: Profile + Navbar

**Branch:** `bugfix/profile-and-navbar`

| # | Bug / Task | File(s) | Done? |
| --- | --- | --- | --- |
| 1 | **Navbar avatar is hardcoded** — The navbar uses a placeholder image URL instead of `current_user.avatar_url`. Fix it to fall back to a generic avatar icon if `avatar_url` is blank | `app/views/shared/_navbar.html.erb` | ⬜ |
| 2 | **Profile page: show latest patch under each followed game** — On the My Profile page, under each game card show the title of the most recent patch (or "No patches yet" if none) | `app/views/pages/my_profile.html.erb` | ⬜ |
| 3 | **Profile page: show upcoming reminders** — On the My Profile page, list the user's upcoming event reminders (event name, date, link) | `app/views/pages/my_profile.html.erb` | ✅ |
| 4 | **Add "Profile" link to navbar dropdown** — Link to `my_profile_path` in the user dropdown menu | `app/views/shared/_navbar.html.erb` | ⬜ |

**Today's progress:** the My Profile page was heavily redesigned into a social-style layout, a new `social_feed_controller.js` was added for tab/interaction behaviour, reminders are now surfaced on the page, and the sidebar links into Find Friends. The navbar-specific fixes are still open.

---

## Demo Flow (End Goal)

The app should demonstrate this flow without errors:

1. Guest visits the home page and can browse games without logging in
2. User logs in with Google (or demo account: `demo@test.com` / `123456`)
3. Games index loads with cover images, search, genre filters, sort
4. User clicks a game and sees the game detail page
5. User clicks Follow on a game
6. User clicks a patch, sees the patch notes + 3 AI summary types, and can chat with the AI
7. User clicks an event, reads the AI summary, and sets a reminder
8. User visits My Profile and sees followed games, recent patches, and upcoming reminders
