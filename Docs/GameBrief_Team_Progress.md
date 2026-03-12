# GameBrief — Team Progress

> Last updated: 2026-03-12

---

## Project Foundation

- Rails app with PostgreSQL, Devise auth, and seeded demo data is in place
- Core models and tables exist for users, games, favourites, patches, patch summaries, events, reminders, chats, and messages
- Root route is the public homepage and the app has custom 404 / 500 handling

## Core Product Areas Completed

### Authentication

- Email/password login and signup work through Devise
- Google OAuth is wired up and previously checked on Heroku
- App-level auth is enforced by default, with public access carved out for the homepage and game browsing

### Games + Following

- IGDB import service built and used in seeds
- Games index supports search, genre filters, and sort options
- Game show page supports follow/unfollow and surfaces related patches/events
- Followed games feed into My Games, My Patches, My Events, and My Profile

### Patches + AI

- Standalone patches index added
- Patch pages support three separate AI summary types
- Patch chatbot shipped with persisted chat/message history and GPT-4o responses via RubyLLM
- Patch date handling improved with `published_at`, sorting, and date filters

### Events + Reminders

- Events index and show pages are live
- Reminder creation/removal works
- Event AI summary generation is live
- My Events page now gives reminders a dedicated destination

### Profile + Discovery

- Dashboard was renamed and reshaped into `My Profile`
- My Profile now includes profile highlights, reminder/patch spotlight cards, notification toggle UI, find-friends entry points, and social/community placeholder sections
- Dedicated `My Games`, `My Patches`, `My Events`, `Find Friends`, and `Players` pages exist

### Scraping + Imports

- Scraper/import flow expanded from the original proof of concept into a shared runner-based system
- `source_url` de-duplication prevents duplicate patch imports
- Multiple game sources are now configured through dedicated scrapers/importers
- Seeds preserve real scraped data where available

## Recent Progress By Session

### Up To 2026-03-11

- Search, genre filters, games sorting, footer, and custom error pages were completed
- Multiple patch summary types were added
- My Profile sidebar navigation, reminders, and followed-game patch surfacing were added
- Standalone patches index and chatbot shipped
- Event AI summaries shipped
- Scraping support expanded across the tracked games list

### 2026-03-12 Status Check

- Homepage brand pass is reflected in code: favicon links in the layout, GameBrief logo on the homepage, and a featured gamers carousel
- My Profile refresh is reflected in code: social-style header/content layout, sidebar notification controls, and recommendation/community placeholder panels
- `My Games`, `My Patches`, and `My Events` are now proper standalone pages rather than just sections on one screen

## Remaining Gaps

- Events index still has no game/time filters
- Patch pages do not yet show a `NEW` badge even though `published_at` now exists
- Summary buttons do not yet show loading/disabled states
- Mobile QA / responsive cleanup still looks unfinished
- Social/community areas on My Profile are mostly mock UI and not backed by real persisted data
