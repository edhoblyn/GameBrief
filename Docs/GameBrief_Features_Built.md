# GameBrief — Implemented Features

---

### Authentication

- Email and password sign up / login via Devise
- Google OAuth login (Sign in with Google) via OmniauthCallbacksController
- All pages require login — unauthenticated users are redirected to sign in
- Public home/landing page accessible without login

### Games

- Games index page with cover art
- Search bar filters games by name
- Genre filter buttons on the games index (Battle Royale, Shooter, Sports, Sandbox, Mobile, etc.)
- Sort games alphabetically (A–Z) or by most-followed
- Follower count shown on each game card
- Visual highlight on games the current user already follows
- Game detail page showing cover image, patches list, and upcoming events

### Following Games

- Follow and unfollow any game from its detail page
- Followed games appear on the user's My Profile page

### Patches

- Patches index page — shows patches from followed games first, then all other patches
- Patch detail page showing full patch notes
- Three AI-generated summary types per patch: **Quick Summary**, **Casual Impact**, and **Should I Log In?**
- Each summary type uses a different Claude prompt and is displayed in its own labelled card
- Separate generate button per summary type — each saved to the database after generation
- Generate buttons hidden once a summary type has already been created
- AI-powered chatbot on each patch page — users can ask questions about the patch in plain English
- Chatbot uses the patch content as context and answers via GPT-4o (via RubyLLM)
- Conversation history persisted in the database so users can ask follow-up questions
- Maximum 10 messages per user per chat to prevent abuse

### Events

- Events index page — shows events from followed games first, then all others
- Event detail page showing description, date, and a link to add it to Google Calendar
- AI-generated one-sentence event summary, generated on demand and saved to the database
- Set and remove reminders on events

### My Profile

- Shows all games the user is following with cover images
- "My Games' Patches" section — recent patches from followed games with links
- "My Reminders" section — all events the user has set reminders for
- Count badges showing number of followed games, patches, and reminders in the My Profile sidebar
- Sidebar navigation on the My Profile page for My Games, My Patches, My Events, and My Recommendations
- Top navbar hidden on the My Profile page so the sidebar becomes the main navigation
- Empty state messages when no games are followed or no reminders are set

### UI + Styling

- Styled game cards, patch cards, and event cards
- Styled Devise login and signup pages
- Footer with app name, year, and team names

### Infrastructure

- IGDB API service (`IgdbClient`) for searching and importing game data using Twitch credentials
- Web scraping for patch imports from official game update pages, with `source_url` de-duplication and recurring background jobs
- Custom 404 "page not found" page
- Custom 500 "something went wrong" page
- Seed file that creates 12 games with real IGDB data, patches, pre-generated summaries, events, and a demo user (`demo@test.com` / `123456`)
- Deployed to Heroku with Heroku Postgres
- Environment variables managed via Heroku Config Vars

---

Last updated: Day 3
