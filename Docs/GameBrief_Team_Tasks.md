# GameBrief — Team Tasks

> Last updated: 2026-03-11 | Focus: Bug Fixes + Web Scraping

---

## Today's Split

| Person | Focus |
| --- | --- |
| Ed | Web scraping (auto-import patch notes) |
| Hortense | Bug fixes — public access + styling |
| Baptiste | Bug fixes — patch/summary issues |
| Bianca | Bug fixes — profile page + navbar |

---

## Ed — Web Scraping

**Branch:** `feature/scraper`

Patches are currently entered manually via seeds. This task builds a scraper to auto-import real patch notes from official game sites.

| # | Task | Done? |
| --- | --- | --- |
| 1 | Add `source_url` string column to `patches` table: `rails g migration AddSourceUrlToPatches source_url:string` then `rails db:migrate` | ⬜ |
| 2 | Add `nokogiri` and `httparty` gems to the Gemfile, then run `bundle install` | ⬜ |
| 3 | Create `app/services/scrapers/base_scraper.rb` with a shared `call` interface (abstract class pattern) | ⬜ |
| 4 | Build one proof-of-concept scraper — e.g. `app/services/scrapers/fortnite_scraper.rb` — that fetches the patch notes list page and returns an array of `{ title:, content:, source_url: }` hashes | ⬜ |
| 5 | Create a rake task `lib/tasks/patches.rake` with `rails patches:scrape` that runs each scraper and upserts results into the `patches` table (use `find_or_create_by(source_url:)` to avoid duplicates) | ⬜ |
| 6 | Test it locally: run `rails patches:scrape` and confirm records appear in the DB | ⬜ |

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
| 3 | **Profile page: show upcoming reminders** — On the My Profile page, list the user's upcoming event reminders (event name, date, link) | `app/views/pages/my_profile.html.erb` | ⬜ |
| 4 | **Add "Profile" link to navbar dropdown** — Link to `my_profile_path` in the user dropdown menu | `app/views/shared/_navbar.html.erb` | ⬜ |

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
