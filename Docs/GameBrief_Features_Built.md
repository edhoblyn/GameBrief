# GameBrief — Implemented Features

---

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

Last updated: Day 2
