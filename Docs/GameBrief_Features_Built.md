# GameBrief — Features Built

> Last updated: 2026-03-13

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
- Signed-in homepage state includes direct link to `My Profile` and logout

## Games

- Games index with search by name
- Genre filters on the index
- Free-to-play filter on the index
- Sort options for A-Z and most followed
- Active game filters can be clicked again to clear just that filter while preserving the rest of the browse state
- Game detail page with follow/unfollow action
- Game detail page lists latest patches and upcoming events
- Admin-only `Run Patch Scrape` action on supported game pages
- Cover art imported from IGDB and lazy-loaded in the game grid

## Follows + Personal Library

- Users can follow and unfollow games
- `My Games` page shows followed games
- Followed games feed into `My Games`, `My Patches`, `My Events`, and `My Profile`
- `My Profile` highlights followed games, the latest followed-game patch, and the next saved event

## Patches

- Standalone patches index page
- Optional nested game patches index under a game
- Game filter on the standalone patches index
- Date filters on patches (`All time`, `Last 7 days`, `Last 30 days`, `Last 90 days`, `This year`)
- Sort modes on patches (`Recommended`, `Newest`, `Oldest`)
- Recommended ordering prioritises followed games first
- Patch detail page shows full notes and published date
- `published_at` support added to patches
- Visible `New` badge for recently published patches
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
- `My Events` page includes reminder counts plus an empty state when no reminders exist
- One-sentence AI event summaries generated and stored on the event record

## My Profile + Discovery

- `My Profile` page rebuilt into a social-style layout
- Sidebar navigation for Home, My Profile, My Games, My Patches, My Events, Recommendations, and Find Friends
- For You / Communities tabbed social-style mock feed on `My Profile`
- Local notification toggle UI for patch alerts, event reminders, and recommendation updates
- `Edit Profile` is linked from the profile page and opens a dedicated account editor
- Users can upload avatar and cover images, which render on profile surfaces
- Username and profile image updates can be saved without a password, while email/password changes still require the current password
- `My Patches` page for followed games with date filters and newest/oldest sorting
- `Find Friends` search page for users by username or email
- Admin-only `Players` index plus individual player profile pages with basic activity counts

## UI / Frontend Polish

- Custom hover-gradient main navigation
- Custom 404 and 500 pages
- App footer with team GitHub profile links
- Mobile responsiveness pass across My Profile, games, patches, and events pages
- Dedicated Stimulus controllers for the featured gamers carousel, social feed interactions, and profile notification toggles

## Data + Infrastructure

- IGDB client for game search/import using Twitch credentials
- Active Storage configured for uploaded profile media
- Seed data for demo user plus featured gamer accounts
- Seed strategy preserves real scraped patches and removes placeholder patches when live scraped data exists
- Scraper/import pipeline expanded across multiple tracked games
- `source_url` de-duplication for imported patches
- Shared `PatchScrapeRunner` service for manual and scheduled imports
- `admin/patch_scrapes#create` route for triggering configured scrape jobs
- Heroku deployment setup with config-var based environment management

## Admin Tools

- Admin-only dashboard protected by `current_user.admin?`
- Manual single-source and run-all patch scrape actions from the admin dashboard
- In-app scrape log output stored in session and rendered after runs
- Admin management UI to promote users by email and remove admins
- Guard to prevent removing the last active admin
