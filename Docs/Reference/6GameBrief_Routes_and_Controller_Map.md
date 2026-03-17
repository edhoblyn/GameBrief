# GameBrief — Routes and Controller Map

> Last updated: 2026-03-17

## Full Routes Overview

```text
root → pages#home

GET  /                         pages#home
GET  /home                     pages#home
GET  /find-friends             pages#find_friends
GET  /my-games                 pages#my_games
GET  /my-patches               pages#my_patches
GET  /my-events                pages#my_events
GET  /my-profile               pages#my_profile

GET  /games                    games#index
GET  /games/:id                games#show
POST /games/suggest            games#suggest
GET  /games/:game_id/patches   patches#index   (nested)

GET  /patches                  patches#index
GET  /patches/:id              patches#show
GET  /patches/:id/notes        patches#notes
POST /patches/:id/generate_summary  patches#generate_summary

POST /patches/:patch_id/chats             chats#create
GET  /patches/:patch_id/chats/:id/stream  chats#stream
POST /patches/:patch_id/chats/:chat_id/messages  messages#create

GET  /events                   events#index
GET  /events/:id               events#show

POST /favourites               favourites#create
DELETE /favourites/:id         favourites#destroy

POST /reminders                reminders#create
DELETE /reminders/:id          reminders#destroy

POST /friendships              friendships#create
DELETE /friendships/:id        friendships#destroy

GET  /users                    users#index   (admin only)
GET  /users/:id                users#show

POST /posts                    posts#create
DELETE /posts/:id              posts#destroy

namespace :admin do
  GET    /admin/dashboard             admin/dashboard#show
  DELETE /admin/chat_history          admin/chat_histories#destroy
  POST   /admin/patch_scrapes         admin/patch_scrapes#create
  POST   /admin/patch_scrapes/run_all admin/patch_scrapes#run_all
  POST   /admin/event_imports         admin/event_imports#create
  POST   /admin/event_imports/run_all admin/event_imports#run_all
  POST   /admin/users                 admin/users#create
  DELETE /admin/users/:id             admin/users#destroy
end

Devise routes:
  GET    /users/sign_in
  POST   /users/sign_in
  DELETE /users/sign_out
  GET    /users/sign_up
  POST   /users/sign_up
  GET    /users/auth/google_oauth2/callback
  GET/POST /users/password/* (reset flow)

Error pages:
  /404  errors#not_found
  /500  errors#server_error
```

## Controller Responsibilities

### PagesController

- `home` — public landing page with featured gamers carousel
- `my_games` — followed games list
- `my_patches` — patches for followed games with date/sort filters
- `my_events` — saved event reminders
- `my_profile` — social-style profile hub
- `find_friends` — user search + friendship management

### GamesController

- `index` — games list with search, genre, free-to-play, and sort filters
- `show` — game detail page with follow/unfollow, patches, and events
- `suggest` — submit a game suggestion

### PatchesController

- `index` — patches list (standalone or nested under a game) with filters and sort
- `show` — patch detail with AI summaries and chatbot
- `notes` — structured patch notes rendered via Turbo frame
- `generate_summary` — trigger Claude AI summary generation for one type

### ChatsController

- `create` — create or retrieve the per-user per-patch chat
- `stream` — SSE endpoint for real-time GPT-4o streaming responses

### MessagesController

- `create` — save a user message, trigger AI response via Turbo Stream

### EventsController

- `index` — events list with time-range and multi-game filters
- `show` — event detail with description, status, countdown, AI summary, and reminder toggle

### FavouritesController

- `create` — follow a game
- `destroy` — unfollow a game

### RemindersController

- `create` — save an event reminder
- `destroy` — remove an event reminder

### FriendshipsController

- `create` — add a friend
- `destroy` — remove a friend

### PostsController

- `create` — create a social post
- `destroy` — delete a social post

### UsersController

- `index` — all users (admin only)
- `show` — individual player profile

### OmniauthCallbacksController (`users/omniauth_callbacks`)

Handles Google OAuth callback; finds or creates a user record.

### RegistrationsController (`users/registrations`)

Custom Devise registrations controller; allows profile updates without requiring password re-entry for non-credential changes.

### Admin::BaseController

Base class for all admin controllers; enforces `current_user.admin?`.

### Admin::DashboardController

- `show` — admin dashboard with recent scrape/import logs and manual trigger actions

### Admin::PatchScrapesController

- `create` — run a single configured patch scraper
- `run_all` — run all enabled patch scrapers

### Admin::EventImportsController

- `create` — run a single configured event importer
- `run_all` — run all enabled event importers

### Admin::UsersController

- `create` — promote a user to admin by email
- `destroy` — remove admin role (guarded against removing the last admin)

### Admin::ChatHistoriesController

- `destroy` — clear chat history for the current admin user

### ErrorsController

- `not_found` — renders custom 404 page
- `server_error` — renders custom 500 page
