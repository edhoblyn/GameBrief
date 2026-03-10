# GameBrief — Planned & Stretch Features

---

## Planned Features
*These are in the current task rounds and will be built before the demo.*

### AI Summaries — Multiple Types

- Three summary types per patch: **Quick Summary**, **Casual Impact**, and **Should I Log In?**
- Each type uses a different Claude prompt tailored to that audience
- Three separate generate buttons on the patch page, one per type
- Each type displayed in its own labelled card

### Search

- Search bar on the games index that filters games by name in real time

### My Profile Page (renamed from Dashboard)

- **Rename "Dashboard" to "My Profile"** across the app (navbar link, routes, page title)
- Cover images on followed game cards
- Latest patch title shown under each game card
- "My Game's Patches" section — list of recent patches from games the user follows, with links and a short summary
- Upcoming events section loaded from the user's active reminders
- Count badges showing number of followed games and upcoming reminders
- "My Reminders" section listing all events the user has set reminders for
- **Sidebar navigation** (replaces top navbar on this page):
  - My Games
  - My Patches
  - My Events
  - Communities
  - My Recommendations (maybe)
- Top navbar hidden on the My Profile page — sidebar takes over navigation

### Patches Page — Dedicated Page + Chatbot

- **Patches link in the main navbar** — takes users to a dedicated patches index page
- The patches index shows patches from games the user follows, plus recommended patches, plus all recent patches (tabbed or sectioned)
- **Integrated AI chatbot on each patch page** — collapsible panel where users can ask questions about the patch in plain English (e.g. "Did they nerf snipers?")
- Chatbot uses the patch content as context and answers via Claude
- Conversation history kept for the session so users can ask follow-up questions

### Events Page Improvements

- **Event type filter** — toggle between In-Game events and IRL events (conventions, esports tournaments, launch events)
- **Game filter** — dropdown to show events for a specific game only
- **Time period filter** — filter by This Week / This Month / Future / All
- All three filters work together using AND logic — combining them narrows results
- IRL events sourced from IGDB or scraped from official sources
- Same reminder and Google Calendar functionality for both event types

### Patches & Events — Personalised + Recommended + Full Browse

- **Followed content** — patches and events from games the user follows shown first
- **Recommendations** — patches and events from similar or popular games suggested below followed content
- **All content** — full browse of all patches and events for users who want to explore
- This structure applies to both the patches index and the events index

### User Profile Page

- Dedicated profile page showing email, join date, and usage stats
- Stat summary: number of followed games and reminders set
- Link in the navbar dropdown
- Option to delete account

### Styling + Polish

- Navbar with My Profile and Patches links
- Styled patch notes page and summary cards
- Styled Devise login and signup pages
- Footer with app name, year, and team names
- Loading/disabled state on the Generate Summary button to prevent double-clicks

### Mobile Responsiveness

- All pages checked and fixed for mobile screen sizes

### Error Pages

- Custom 404 "page not found" page
- Custom 500 "something went wrong" page

### Games Index Improvements

- Sort games alphabetically or by most-followed
- Follower count badge on each game card
- Visual highlight on games the current user already follows
- "Popular Games" section at the top showing the 3 most-followed games
- **Genre filter** — tag each game with a genre (FPS, Sports, Battle Royale, RPG, Sandbox, Mobile) and add filter buttons to the games index so users can browse by category

### Patch Improvements

- Publish date shown on patch cards and the patch detail page
- Patches ordered by most recent first
- "Back to game" breadcrumb link on the patch page
- Hide generate buttons once all 3 summary types have been created

---

## Web Scraping — Auto-Import Game Data

*Replacing manual data entry with automated imports from public sources.*

Right now patches and events are entered manually. Web scraping would let the app pull real patch notes and event data automatically, keeping content fresh without anyone on the team having to do it by hand.

### Patch Notes Scraping

- Scrape official patch note pages for each game (e.g. Fortnite, League of Legends, Valorant all publish patch notes at predictable URLs)
- Use `Nokogiri` (HTML parsing) or `Mechanize` (for pages that need cookie/session handling)
- Parse the page and save new entries as `Patch` records — skip if already imported (deduplicate by title or URL)
- Run on a schedule using a background job (e.g. `Sidekiq` + `sidekiq-cron`, or a Heroku Scheduler task)

### Sources by Game

| Game | Patch Note Source |
| --- | --- |
| Fortnite | `fortnite.com/en-US/news/patch-notes` |
| League of Legends | `leagueoflegends.com/en-us/news/tags/patch-notes` |
| Valorant | `playvalorant.com/en-us/news/tags/patch-notes` |
| Apex Legends | `ea.com/games/apex-legends/news/tags/patch-notes` |
| Call of Duty / Warzone | `callofduty.com/blog` |
| Others | Check each game's official news/blog page |

### Events Scraping

- Scrape esports and in-game event announcements from official game sites or their news feeds
- Some games expose RSS feeds — these are easier to parse than raw HTML
- IGDB API already covers some events — scraping fills the gaps

### Technical Approach

- `Nokogiri` gem for HTML parsing — already widely used in Rails projects
- `HTTParty` or `Faraday` for making HTTP requests
- Store a `source_url` column on `patches` and `events` to track where each record came from and avoid duplicates
- A `ScraperService` per game, each with a `call` method that returns an array of hashes ready to upsert
- Heroku Scheduler (free add-on) to trigger scraping daily or on a set interval

---

## Stretch Features
*Nice to have — attempt if there is time after planned features are complete.*

### Activity Feed on Dashboard

- "Recent Updates" section showing the 5 most recent patches from games the user follows
- Each item shows game name, patch title, date, and a link to the patch

### "New" Badge on Patches

- `published_at` date added to patches
- Green "NEW" badge shown on any patch published within the last 7 days

### AI Event Summary

- One-sentence AI summary for events generated on demand
- "Summarise Event" button on the event detail page
- Summary saved and displayed at the top of the page on future visits

### Email Confirmation for Reminders

- Confirmation email sent to the user when they set a reminder
- Email includes event name, date, and a link back to the event page

### Age Verification on Signup

- Collect date of birth during the Devise sign up flow
- Store age on the user record
- Games with an 18+ rating are hidden from users under 18 until they reach that age
- Age check runs automatically without requiring the user to re-verify

### IRL Events Section

- Separate section for real-world gaming events (conventions, esports tournaments, launch events) sourced from IGDB
- Branded as "IRL Events" to match gaming language
- Same reminder and Google Calendar functionality as in-game events

### Upcoming Games

- Dedicated page or section showing games that are not yet released
- Data sourced from IGDB (release dates and upcoming titles)
- Users can follow upcoming games and get notified when they launch

### AI Chatbot

- A chat interface where users can ask questions about a game's patch notes in plain English
- e.g. "Did they nerf snipers in the latest patch?" or "What changed for support characters?"
- The chatbot is given the patch content as context and answers using Claude
- Could live on the patch show page as a collapsible chat panel, or as a floating button across the whole app
- Conversation history kept for the session so users can ask follow-up questions

### Live Streamers on Game Page

- On each game's detail page, show a live panel of streamers currently streaming that game on Twitch and/or Kick
- Pull data from the **Twitch API** (`GET /streams?game_id=...`) and optionally the **Kick API** if available
- Each streamer card shows: avatar, username, stream title, viewer count, and a link to their stream
- Limit to top 6–8 streamers by viewer count
- Panel only shows when there are active streams — hidden if no one is live
- Could be a separate section at the bottom of `games/show.html.erb` labelled "Watch Live"
- Twitch requires a client credentials OAuth token — similar setup to the IGDB integration (both use Twitch credentials)

### Personalisation

- **Game genre tags** — tag games with genres (FPS, RPG, Battle Royale, MOBA) so users can filter the games index by genre
- **"For You" recommendations** — suggest games similar to ones the user already follows, based on genre or popularity
- **Notification preferences** — let users choose what they get alerted for: new patches, upcoming events, or both

### Content

- **Patch difficulty rating** — after reading a patch, users rate it "Minor Update", "Major Update", or "Game Changer" to help others gauge how significant it is
- **Patch reading history** — track which patches the user has already read so they don't lose their place across visits
- **Game ratings and reviews** — leave a short review on the game page with a star rating and one-line comment

### Gamification

- **Achievements and badges** — earn badges for milestones like "Followed 5 games", "Read 10 patches", "Set your first reminder"
- **Streak tracking** — reward users who check in daily to read patch notes, shown on their profile

### Utility

- **Platform tags** — label each game as PC, Console, or Mobile so users know where they can play it
- **Free to play filter** — filter the games index to show only free-to-play titles
- **Push notifications** — browser or mobile notifications when a followed game gets a new patch or event

### Social Features

- **Activity feed** — a personalised feed showing recent patches, events, and updates from games the user follows, ordered by date
- **Follow other users** — follow friends or other players to see what games they are following and what patches they are reading
- **Player profiles** — public profile pages showing a user's followed games, recent activity, and bio
- **Find other players** — discover users who follow the same games as you, useful for finding teammates or people to play with
- **Game chat rooms** — a chat room per game where followers can discuss patches and updates together in real time (could use ActionCable for live updates)
- **Patch comments** — leave a comment on a patch page to share reactions or tips with other players who follow the same game
- **Direct messaging** — send messages to other users directly within the app
- **Share a patch** — share a patch via a link or in-app share button to send to a friend

---

## Product Ideas
*Not features to build now — ideas for how the app could grow in the future.*

### Developer-Facing Features

- GameBrief could be marketed to game developers as a discovery and retention tool
- New players can find games through the platform
- Existing players are more likely to return when patch notes are easy to understand
- Potential for a developer dashboard showing how many users follow their game and read patch notes

---

Last updated: Day 2
