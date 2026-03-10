# GameBrief — Feature List

---

## Implemented Features

### Authentication
- Email and password sign up / login via Devise
- Google OAuth login (Sign in with Google)
- All pages require login — unauthenticated users are redirected

### Games
- Games index page with cover art loaded from IGDB
- Game detail page showing description, patches, and upcoming events
- 12 games seeded with real data from the IGDB API

### Following Games
- Follow and unfollow any game from its detail page
- Followed games appear on the user's dashboard

### Patches
- Patch list per game
- Patch detail page showing full patch notes
- AI-generated summary for each patch (one summary type, generated on demand)
- Summary is saved to the database after generation — not re-generated on each visit

### Events
- Event list page
- Event detail page showing description, date, and a link to add it to Google Calendar
- Set and remove reminders on events

### Dashboard
- Shows all games the user is following
- Empty state message if the user has not followed any games

### Infrastructure
- Deployed to Heroku with Heroku Postgres
- Environment variables managed via Heroku Config Vars
- Seed file that imports all 12 games from IGDB and creates patches, summaries, and events

---

## Planned Features

### AI Summaries — Multiple Types
- Three summary types per patch: **Quick Summary**, **Casual Impact**, and **Should I Log In?**
- Each type uses a different Claude prompt tailored to that audience
- Three separate generate buttons on the patch page, one per type
- Each type displayed in its own labelled card

### Search
- Search bar on the games index that filters games by name in real time

### Dashboard Improvements
- Cover images on followed game cards (not just text links)
- Latest patch title shown under each game card
- Upcoming events section loaded from the user's active reminders
- Count badges showing number of followed games and upcoming reminders
- "My Reminders" section listing all events the user has set reminders for

### User Profile Page
- Dedicated profile page showing email, join date, and usage stats
- Stat summary: number of followed games and reminders set
- Link in the navbar dropdown
- Option to delete account

### Styling + Polish
- Navbar with Dashboard and Profile links
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

### Patch Improvements
- Publish date shown on patch cards and the patch detail page
- Patches ordered by most recent first
- "Back to game" breadcrumb link on the patch page
- Hide generate buttons once all 3 summary types have been created

---

## Stretch Features (if time allows)

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

---

## Product Ideas

These are not features to build right now but could shape how the app is positioned in the future.

### Developer-Facing Features

- GameBrief could be marketed to game developers as a discovery and retention tool
- New players can find games through the platform
- Existing players are more likely to return when patch notes are easy to understand
- Potential for a developer dashboard showing how many users follow their game and read patch notes

---

Last updated: Day 2
