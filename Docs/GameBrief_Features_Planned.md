# GameBrief — Planned & Stretch Features

---

## Planned Features
*In scope for the demo — build these before presenting.*

### Styling + Polish

- Styled game cards, patch cards, and event cards
- Styled patch summary cards (one card per summary type)
- Styled Devise login and signup pages
- Loading/disabled state on Generate Summary buttons to prevent double-clicks
- Footer with app name, year, and team names
- Mobile responsiveness — all pages checked and fixed for small screens

### My Profile Improvements

- Count badges showing number of followed games and upcoming reminders
- Sidebar navigation (replaces top navbar on the My Profile page):
  - My Games
  - My Patches
  - My Events
  - Communities *(placeholder — coming soon)*
  - My Recommendations *(placeholder — coming soon)*
- Top navbar hidden on the My Profile page — sidebar takes over navigation

### Events Page Filters

- **Game filter** — dropdown to show events for a specific game only
- **Time period filter** — filter by This Week / This Month / Future / All

### Web Scraping — Auto-Import Game Data

Right now patches and events are entered manually. Web scraping would pull real patch notes and event data automatically, keeping content fresh without manual entry.

- Scrape official patch note pages for each game (Fortnite, Valorant, Apex, etc.)
- Use `Nokogiri` for HTML parsing and `HTTParty`/`Faraday` for HTTP requests
- Deduplicate by title or source URL — skip records already imported
- Store a `source_url` column on `patches` and `events`
- Schedule scraping daily using Heroku Scheduler or a background job

### Email Confirmation for Reminders

- Confirmation email sent when a user sets a reminder
- Email includes event name, date, and a link back to the event page

### "New" Badge on Patches

- `published_at` date added to patches
- Green "NEW" badge on any patch published within the last 7 days

### Live Streamers on Game Page

- Panel on each game's detail page showing streamers currently live on Twitch
- Pull from the Twitch API (`GET /streams?game_id=...`)
- Each card shows: avatar, username, stream title, viewer count, and a link to their stream
- Limit to top 6–8 by viewer count; panel hidden when no one is live
- Uses same Twitch credentials as the IGDB integration

### Social Features

- **Activity feed** — personalised feed of recent patches and events from followed games
- **Follow other users** — see what games friends are following
- **Public player profiles** — followed games, recent activity, bio
- **Patch comments** — leave reactions or tips on a patch page
- **Share a patch** — share via a link or in-app share button

### Gamification

- **Achievements and badges** — earn badges for milestones like "Followed 5 games" or "Set your first reminder"
- **Streak tracking** — reward users who check in daily to read patch notes

### Personalisation

- **"For You" recommendations** — suggest games similar to ones the user follows, based on genre or popularity
- **Notification preferences** — choose what to get alerted for: new patches, upcoming events, or both

### Utility

- **Platform tags** — label each game as PC, Console, or Mobile
- **Free to play filter** — filter the games index to show only free-to-play titles
- **Pagination** — paginate games, patches, and events list pages
- **Age verification on signup** — collect date of birth; hide 18+ rated games from underage users

### Upcoming Games

- Dedicated section showing unreleased games sourced from IGDB
- Users can follow upcoming games and get notified at launch

---

## Product Ideas
*Not features to build now — ideas for how the app could grow.*

### Developer-Facing Features

- GameBrief marketed to game developers as a discovery and retention tool
- New players can find games through the platform
- Existing players more likely to return when patch notes are easy to understand
- Potential developer dashboard showing follower counts and patch read rates

---

Last updated: Day 3
