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
- Patch freshness badge work is now reflected in code: recent patches with a real `published_at` from the last 7 days now surface a visible `New` badge across patch cards and related patch lists
- A first mobile responsiveness pass is now reflected in code: My Profile, games, patches, and events layouts have improved small-screen spacing, button stacking, and card behaviour for demo use
- Games index free-to-play support is now reflected in code: `games` has a real `free_to_play` flag, the current tracked titles are classified, and the games index exposes a working `Free-to-play` filter
- Games index filter UX was tightened after that change: active game filter chips can now be clicked again to clear just that filter while preserving the rest of the current browse state
- Edit Profile is now a usable account editor linked from `My Profile`, with clearer separation between public profile updates and login/security changes
- Users can now upload avatar and cover images with Active Storage, and those uploads now render back into the profile header/sidebar after saving
- Profile/account update rules were tightened so username and profile image changes can be saved without a password, while email/password changes still require the current password
- Small stability fixes landed around nil-safe navigation counts and public game show handling

## Completed Tasks Moved From The Task Board

### Completed Task A - Baptiste

**Brand Pass** 🔵

**Task:** **Change the browser tab icon and add the GameBrief logo on the homepage**

**Done?** ✅

### Completed Task B - Hortense / Bianca / Ed

**Profile Refresh** 🔴

**Task:** **My Profile layout and sidebar updates** — reduce empty space, rebuild the profile layout, and make the sidebar / notification controls fit the new structure

**Done?** ✅

### Completed Task C - Team

**Profile Split** 🟢

**Task:** **Dedicated profile sub-pages** — move My Games, My Patches, and My Events into proper standalone pages

**Done?** ✅

### Completed Task D - Ed

**Fresh Badge** 🩷

**Task:** **"New" badge on patches** — use `published_at` and show a visible badge on recent patches from the last 7 days on patch cards and relevant views

**Done?** ✅

### Completed Task E - Ed

**Mobile Sweep** ⭐️

**Task:** **Mobile responsiveness pass** — check and fix My Profile, patches, events, and games pages on small screens

**Done?** ✅

### Completed Task F - Ed

**Free Queue** 💙

**Task:** **Free-to-play filter** — add a real free-to-play filter on the games index, including any data support needed for the current tracked games

**Done?** ✅

### Completed Task G - Bianca / Ed

**Profile Identity** 🩵

**Task:** **Edit profile and image upload pass** — make the profile edit flow usable from `My Profile`, add avatar/cover uploads, and clarify when the current password is required

**Done?** ✅

## Remaining Gaps

- Events index still has no game/time filters
- Summary buttons do not yet show loading/disabled states
- Social/community areas on My Profile are mostly mock UI and not backed by real persisted data
- My Profile recommendations still need a first real recommendation block instead of placeholder content
- Notifications still imply a destination page that does not yet exist in-app
- Admin scrape access still needs a clean end-to-end check against the current `current_user.admin?` gate
