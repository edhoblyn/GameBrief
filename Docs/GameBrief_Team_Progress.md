# GameBrief — Team Progress

> Last updated: 2026-03-13

---

## Project Foundation

- Rails app with PostgreSQL, Devise auth, and seeded demo data is in place
- Core models and tables exist for users, games, favourites, patches, patch summaries, events, reminders, chats, and messages
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

### Events + Reminders

- Events index and show pages are live
- Reminder creation/removal works
- Event AI summary generation is live
- `My Events` gives reminders a dedicated destination

### Profile + Discovery

- Dashboard was renamed and reshaped into `My Profile`
- `My Profile` now includes profile highlights, reminder/patch spotlight cards, notification toggle UI, and find-friends entry points
- `My Profile` also includes a tabbed `For You` / `Communities` presentation layer, but that content is still mostly mock/demo-first
- Dedicated `My Games`, `My Patches`, `My Events`, and `Find Friends` pages exist
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

### Up To 2026-03-13

- Homepage brand pass is reflected in code: favicon links in the layout, GameBrief logo on the homepage, and a featured gamers carousel
- My Profile refresh is reflected in code: social-style header/content layout, sidebar notification controls, and recommendation/community placeholder panels
- `My Games`, `My Patches`, and `My Events` are proper standalone pages rather than sections on one screen
- Patch freshness badge work is reflected in code: recent patches with a real `published_at` from the last 7 days surface a visible `New` badge
- A first mobile responsiveness pass is reflected in code across My Profile, games, patches, and events
- Games index free-to-play support is reflected in code: `games` has a real `free_to_play` flag and the index exposes a working `Free-to-play` filter
- Games index filter UX was tightened so active game filter chips can clear individually without losing the rest of the browse state
- Edit Profile is now a usable account editor linked from `My Profile`, with clearer separation between public profile updates and login/security changes
- Users can upload avatar and cover images with Active Storage, and those uploads render back into the profile header/sidebar after saving
- Admin tooling is reflected in code: the admin dashboard exposes manual scrape triggers, scrape logs, and admin role management behind the `current_user.admin?` gate
- `My Events` has a dedicated empty state when a user has no reminders saved

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

## Remaining Gaps

- Events index still has no game/time filters
- Summary buttons do not yet show loading/disabled states
- Social/community areas on `My Profile` are mostly mock UI and not backed by persisted app data
- `My Profile` recommendations still need a first real recommendation block instead of placeholder content
- Notification toggles are still `localStorage` UI state rather than persisted user preferences
- The bio and several profile stats shown on `My Profile` are still hard-coded view content rather than editable user data
