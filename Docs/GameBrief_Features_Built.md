# GameBrief — Features Built

> Last updated: 2026-03-12

---

## Authentication + Access

- Devise email/password sign up and login
- Google OAuth login via `users/omniauth_callbacks`
- Global `authenticate_user!` in `ApplicationController`
- Public landing page at `pages#home`
- Public games browsing on `games#index` and `games#show`

## Homepage

- Video-based landing page with GameBrief logo and CTA buttons
- Browser tab icons configured in the main layout
- Featured gamers carousel driven by seeded user profiles
- Signed-in homepage state includes direct link to My Profile and a logout action

## Games

- Games index with search by name
- Genre filters on the index (`Shooter`, `Battle Royale`, `Strategy`, `Sports`, `Sandbox`, `Simulation`, `Mobile`)
- Sort options for A-Z and most followed
- Game detail page with follow/unfollow action
- Game detail page lists latest patches and upcoming events
- Cover art imported from IGDB and lazy-loaded in game grids

## Follows + Personal Library

- Users can follow and unfollow games
- `My Games` page shows all followed games
- `My Profile` highlights followed games, latest followed-game patch, and next saved event

## Patches

- Standalone patches index page
- Optional nested game patches index under a game
- Game filter on the standalone patches index
- Date filters on patches (`All time`, `Last 7 days`, `Last 30 days`, `Last 90 days`, `This year`)
- Sort modes on patches (`Recommended`, `Newest`, `Oldest`)
- Recommended ordering prioritises followed games first
- Patch detail page shows full notes and published date
- `published_at` support added to patches
- Patch date fallback logic handles imported data, seeded demo content, and missing dates
- Scraped patches are prioritised ahead of placeholder/manual patches on game pages

## AI Patch Summaries

- Three stored patch summary types: `Quick Summary`, `Casual Impact`, and `Should I Log In?`
- Generate action per summary type on the patch page
- Existing summary for a type is replaced on regeneration
- Summary labels and prompts are centralised in `SummaryService`

## Patch Chatbot

- One chat per user per patch
- Persisted user and assistant messages
- GPT-4o responses generated through RubyLLM
- Prior chat history is replayed for follow-up questions
- Patch content is injected into chatbot instructions for context
- User message limit of 10 per chat

## Events + Reminders

- Events index ordered with followed-game events first
- Event detail page with title, game link, description, and date
- Google Calendar add link on each event
- Set and remove reminders
- `My Events` page lists saved reminders
- One-sentence AI event summaries generated and stored on the event record

## My Profile + Discovery

- `My Profile` page rebuilt into a social-style layout
- Sidebar navigation for Home, My Profile, My Games, My Patches, My Events, Recommendations, and Find Friends
- Local notification toggle UI for patch alerts, event reminders, and recommendation updates
- `My Patches` page for followed games with date filters and newest/oldest sorting
- `Find Friends` search page for users by username or email
- Basic `Players` index page

## UI / Frontend Polish

- Custom hover-gradient main navigation
- Custom 404 and 500 pages
- App footer with team GitHub profile links
- Dedicated Stimulus controllers for featured gamers carousel, social feed interactions, and profile notification toggles

## Data + Infrastructure

- IGDB client for game search/import using Twitch credentials
- Seed data for demo user plus featured gamer accounts
- Seed strategy preserves real scraped patches and removes placeholder patches when live scraped data exists
- Scraper/import pipeline expanded across multiple games
- `source_url` de-duplication for imported patches
- Shared `PatchScrapeRunner` service for manual and scheduled imports
- `admin/patch_scrapes#create` route for triggering configured scrape jobs
- Deployed on Heroku with config-var based environment management
