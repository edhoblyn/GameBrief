# GameBrief — Team Progress

> Last updated: 2026-03-14

---

## Project Foundation

- Rails app with PostgreSQL, Devise auth, and seeded demo data is in place
- Core models and tables exist for users, games, favourites, patches, patch summaries, events, reminders, chats, messages, and friendships
- Root route is the public homepage and the app has custom `404` / `500` handling

## Core Product Areas Completed

### Authentication

- Email/password login and signup work through Devise
- Google OAuth is wired up through OmniAuth
- App-level auth is enforced by default, with public access carved out for the homepage and game browsing

### Games + Following

- IGDB import service exists and is used in seeds
- Games index supports search, genre filters, free-to-play filtering, and sort options
- Game show pages support follow/unfollow and surface related patches/events
- Followed games feed into `My Games`, `My Patches`, `My Events`, and `My Profile`

### Patches + AI

- Standalone patches index is live
- Patch pages support three separate AI summary types
- Patch chatbot shipped with persisted chat/message history and GPT-4o responses via RubyLLM
- Patch date handling includes `published_at`, sorting, date filters, and freshness badges
- Scraped patch notes can be converted into structured AI presentation with a visible pending/progress state

### Events + Reminders

- Events index and show pages are live
- Events index now supports time-range and multi-game filtering
- Reminder creation/removal works
- Event AI summary generation is live
- `My Events` gives reminders a dedicated destination

### Profile + Discovery

- Dashboard was renamed and reshaped into `My Profile`
- `My Profile` now includes profile highlights, reminder/patch spotlight cards, notification toggle UI, and find-friends entry points
- `My Profile` also includes a tabbed `For You` / `Communities` presentation layer, but that content is still mostly mock/demo-first
- Dedicated `My Games`, `My Patches`, `My Events`, and `Find Friends` pages exist
- Friendship create/remove flows are live from `Find Friends`
- Individual player profile pages exist, and the full `Players` index exists behind admin access

### Scraping + Imports

- Scraper/import flow expanded into a shared runner-based system
- `source_url` de-duplication prevents duplicate patch imports
- Multiple game sources are configured through dedicated scrapers/importers
- Seeds preserve real scraped data where available

### Admin + Account Management

- Admin-only dashboard exists for manual scrape actions
- Admins can run single-source scrapes or a run-all action from the UI
- Scrape results are surfaced back into the dashboard as a log feed
- Admin role management exists in-app with add/remove actions
- The last remaining admin cannot be removed
- Account updates support avatar/cover uploads and no-password profile updates for non-credential changes

## Recent Progress Reflected In Code

### Up To 2026-03-14

- Events filtering is reflected in code and tests: `events#index` now ships time-range filters plus multi-game filtering with preserved UI state
- Friendship work is reflected in code: `Find Friends` can search users and create/remove persisted friendships
- Event detail pages are richer in code: status pills, countdown, related events, reminder state, and latest-patch context are all rendered
- Patch presentation work is reflected in code: scraped notes can show AI progress first, then upgrade into structured accordion sections
- Previous profile/account work remains reflected in code: avatar/cover uploads, no-password profile edits, and the split `My Games` / `My Patches` / `My Events` pages

## Completed Tasks Moved From The Task Board

### Completed Task A - Baptiste

**Brand Pass** 🔵

**Task:** Change the browser tab icon and add the GameBrief logo on the homepage

**Done?** ✅

### Completed Task B - Hortense / Bianca / Ed

**Profile Refresh** 🔴

**Task:** Rebuild the `My Profile` layout and sidebar structure

**Done?** ✅

### Completed Task C - Team

**Profile Split** 🟢

**Task:** Move `My Games`, `My Patches`, and `My Events` into standalone pages

**Done?** ✅

### Completed Task D - Ed

**Fresh Badge** 🩷

**Task:** Add a `New` badge on recent patches using `published_at`

**Done?** ✅

### Completed Task E - Ed

**Mobile Sweep** ⭐️

**Task:** Improve My Profile, patches, events, and games layouts on small screens

**Done?** ✅

### Completed Task F - Ed

**Free Queue** 💙

**Task:** Add a real free-to-play filter on the games index

**Done?** ✅

### Completed Task G - Bianca / Ed

**Profile Identity** 🩵

**Task:** Make the profile edit flow usable, add avatar/cover uploads, and clarify when the current password is required

**Done?** ✅

### Completed Task H - Team

**Event Filters** 🟣

**Task:** Add events index filters for game and time range (`This Week`, `This Month`, `Future`, `All`) and reflect the active filter state in the UI

**Done?** ✅

## Remaining Gaps

- Notification toggles are still `localStorage` UI state rather than persisted user preferences
- `My Profile` recommendations still need a first real recommendation block instead of placeholder content
- The bio and several profile stats shown on `My Profile` are still hard-coded view content rather than editable user data
- Social/community areas on `My Profile` are mostly mock UI and not backed by persisted app data
- Patch summary generation actions still do not show strong loading/disabled feedback during requests
- There is still no user-facing history surface for reopening older patch chats
