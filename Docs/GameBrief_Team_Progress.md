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

### Person 1 — Authentication
- Devise installed and configured
- Email/password login and signup working
- `authenticate_user!` applied globally in ApplicationController
- Google OAuth wired up: `OmniauthCallbacksController` created, routes updated, `from_omniauth` on User model, `provider`/`uid` migration added
- `:omniauthable` added to User model

### Person 2 — Games + IGDB
- `IgdbClient` service built with Twitch OAuth token fetch and game search
- Seeds import real games from IGDB with cover images
- `games/index.html.erb` lists games with links
- `games/show.html.erb` shows game detail, patches, follow/unfollow button, and upcoming events
- Game model has all associations: patches, events, favourites

### Person 3 — Patches + Summaries
- `Patch` model has `belongs_to :game` and `has_many :patch_summaries`
- `PatchSummary` model has `belongs_to :patch`
- `PatchesController` with index (scoped to game) and show (includes summaries)
- `patches/show.html.erb` displays patch notes and AI summary cards
- `patches/index.html.erb` lists patches for a game
- Routes set up with nested patches under games

### Person 4 — Events + Favourites
- `FavouritesController` with create and destroy
- Follow/unfollow buttons on `games/show.html.erb`
- `EventsController` with index and show
- `events/show.html.erb` displays event detail and Google Calendar link
- `events/index.html.erb` lists events
- Reminder and Event models have correct associations

---

## Round 2 Tasks

### Person 1 — Finish Google OAuth + Deploy to Heroku
**Branch:** `feature/authentication`

| # | Task |
|---|------|
| 1 | Open `config/initializers/devise.rb` and add Google OAuth client ID and secret config |
| 2 | Test Google login works locally end-to-end |
| 3 | Merge into master |
| 4 | `git push heroku master` |
| 5 | `heroku run rails db:migrate` |
| 6 | `heroku run rails db:seed` |
| 7 | Visit the live Heroku URL and confirm login and games page load correctly |

---

### Person 2 — Styling
**Branch:** `feature/styling`

| # | Task |
|---|------|
| 1 | Pull latest master |
| 2 | Replace Le Wagon placeholder logo in navbar with GameBrief app name |
| 3 | Replace placeholder `"Home"` link with `link_to "Games", games_path` |
| 4 | Remove the placeholder `"Messages"` link from navbar |
| 5 | Style `games/index.html.erb` — Bootstrap card grid with cover image, game name, and link on each card |
| 6 | Style `games/show.html.erb` — cover image, patch list, events list |
| 7 | Style the Devise login/signup pages |

---

### Person 3 — AI Summaries
**Branch:** `feature/ai-summaries`

| # | Task |
|---|------|
| 1 | Add `gem "anthropic"` to Gemfile and run `bundle install` |
| 2 | Add `ANTHROPIC_API_KEY` to `.env` |
| 3 | Create `app/services/summary_service.rb` — takes a `patch`, calls Claude API, returns a summary string |
| 4 | Add a `generate_summary` action to `PatchesController` |
| 5 | Add the route: `post /patches/:id/generate_summary` |
| 6 | Add a "Generate Summary" button to `patches/show.html.erb` |
| 7 | Test that clicking the button saves a new `PatchSummary` record and displays it |

---

### Person 4 — Reminders + Dashboard
**Branch:** `feature/reminders-dashboard`

| # | Task |
|---|------|
| 1 | Add `belongs_to :user` and `belongs_to :event` to the `Reminder` model |
| 2 | Update `EventsController#show` to load `@reminder = current_user.reminders.find_by(event: @event)` |
| 3 | Add Set Reminder / Remove Reminder buttons to `events/show.html.erb` |
| 4 | Add `create` and `destroy` actions to `RemindersController` |
| 5 | Create `app/views/pages/dashboard.html.erb` showing the user's followed games |
| 6 | Add a `dashboard` action to `PagesController` loading `@followed_games = current_user.favourite_games` |
| 7 | Add `get "dashboard", to: "pages#dashboard"` to `routes.rb` |
| 8 | Add a Dashboard link to the navbar |

---

## Round 3 Tasks

### Person 1 — Polish + Heroku Maintenance
**Branch:** `feature/polish`

| # | Task |
|---|------|
| 1 | Add `ANTHROPIC_API_KEY` to Heroku config vars once Person 3 has the key |
| 2 | Run `heroku run rails db:seed` after each major merge to keep Heroku data fresh |
| 3 | Add Heroku redirect URI to Google Cloud Console: `https://gamebrief.herokuapp.com/users/auth/google_oauth2/callback` |
| 4 | Smoke test the full demo flow on Heroku: login → games → patch → follow → event |
| 5 | Fix any bugs found during the demo walkthrough |

---

### Person 2 — Styling Round 2
**Branch:** `feature/styling-2`

| # | Task |
|---|------|
| 1 | Style `patches/show.html.erb` — format patch notes and summary card nicely |
| 2 | Style `events/index.html.erb` and `events/show.html.erb` |
| 3 | Style the dashboard page once Person 4 builds it |
| 4 | Make the app mobile-friendly — check all pages on a small screen |
| 5 | Add a loading state or disabled state to the Generate Summary button |

---

### Person 3 — Summary Polish
**Branch:** `feature/ai-summaries-2`

| # | Task |
|---|------|
| 1 | Improve the Claude prompt to produce a better casual summary |
| 2 | Prevent duplicate summaries — only show the Generate Summary button if no summary exists yet |
| 3 | Add a flash message confirming the summary was generated |
| 4 | Handle API errors gracefully — show a message if the summary fails |

---

### Person 4 — Dashboard Polish
**Branch:** `feature/dashboard-polish`

| # | Task |
|---|------|
| 1 | Show upcoming events for followed games on the dashboard |
| 2 | Show latest patch for each followed game on the dashboard |
| 3 | Add an empty state message if the user has no followed games |
| 4 | Link each followed game card back to the game show page |

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

*Last updated: Round 1 complete, Round 2 in progress*
