# GameBrief — Planned & Stretch Features

---

## Planned Features
*In scope for the demo — build these before presenting.*

### Highest Demo Priority

- **Web scraping — auto-import game data** — one of the original pitch ideas and a major differentiator for GameBrief
  Right now patches and events are entered manually. Web scraping would pull real patch notes and event data automatically, keeping content fresh without manual entry.
  - Scrape official patch note pages for each game (Fortnite, Valorant, Apex, etc.)
  - Use `Nokogiri` for HTML parsing and `HTTParty`/`Faraday` for HTTP requests
  - Deduplicate by title or source URL — skip records already imported
  - Store a `source_url` column on `patches` and `events`
  - Schedule scraping daily using Heroku Scheduler or a background job
- **Activity feed** — personalised feed of recent patches and events from followed games
- **Events page filters** — game filter plus time period filter (This Week / This Month / Future / All)
- **"New" badge on patches** — add `published_at` and show a green "NEW" badge for the last 7 days
- **Live streamers on game page** — show currently live Twitch streamers for that game
- **Email confirmation for reminders** — send a confirmation email with event details and a link back
- **Patch comparison view** — compare the newest patch with the previous one so users can see what changed quickly
- **Patch difficulty meter** — label updates as low, medium, or high impact for casual players
- **Trending now section** — surface the most-followed or most-viewed games, patches, and events

### Strong Demo Enhancements

- Count badges showing number of followed games and upcoming reminders
- Sidebar navigation (replaces top navbar on the My Profile page):
  - My Games
  - My Patches
  - My Events
  - Communities *(placeholder — coming soon)*
  - My Recommendations *(placeholder — coming soon)*
- Top navbar hidden on the My Profile page — sidebar takes over navigation
- **Saved AI chats** — let users revisit past patch conversations instead of starting over each time
- **Reminder digest emails** — send a weekly email with upcoming followed-game events and fresh patch summaries
- **Notification centre** — an in-app page for new patches, reminders, and recommendation updates
- **"For You" recommendations** — suggest games similar to ones the user follows, based on genre or popularity
- **Player onboarding quiz** — ask users what genres and platforms they like, then pre-fill recommendations
- **Notification preferences** — choose what to get alerted for: new patches, upcoming events, or both
- **Release countdowns** — countdown cards for upcoming game launches, seasons, and major events

### Polish + Utility

- **Platform tags** — label each game as PC, Console, or Mobile
- **Free to play filter** — filter the games index to show only free-to-play titles
- **Pagination** — paginate games, patches, and events list pages
- **Age verification on signup** — collect date of birth; hide 18+ rated games from underage users
- Styled game cards, patch cards, and event cards
- Styled patch summary cards (one card per summary type)
- Styled Devise login and signup pages
- Loading/disabled state on Generate Summary buttons to prevent double-clicks
- Footer with app name, year, and team names
- Mobile responsiveness — all pages checked and fixed for small screens

### Stretch Features

- **Follow other users** — see what games friends are following
- **Public player profiles** — followed games, recent activity, bio
- **Patch comments** — leave reactions or tips on a patch page
- **Patch sentiment reactions** — simple reactions like Hype, Neutral, or Concerned to measure community response
- **Share a patch** — share via a link or in-app share button
- **Achievements and badges** — earn badges for milestones like "Followed 5 games" or "Set your first reminder"
- **Streak tracking** — reward users who check in daily or weekly to read patch notes
- **Community collections** — curated lists like "Best games for quick matches" or "Top active live-service games"
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
