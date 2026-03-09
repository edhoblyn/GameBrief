# GameBrief --- Project Roadmap (2‑Week Project)

This roadmap outlines the **logical order of building features**.

It is not a strict timeline, but it helps the team avoid dependency
problems.

------------------------------------------------------------------------

# Stage 1 --- Project Foundations

Focus on getting the application running.

Tasks: - Rails project setup - PostgreSQL database - Devise
authentication - Google OAuth login

Outcome: Users can log into the application.

------------------------------------------------------------------------

# Stage 2 --- Core Data Models

Create the main models used by the application.

Models:

User\
Game\
Favourite\
Patch\
PatchSummary\
Event\
Reminder

Outcome: Database structure is ready for features.

------------------------------------------------------------------------

# Stage 3 --- Game Catalogue

Integrate the **IGDB API**.

Tasks:

-   Create IGDB service
-   Import games
-   Populate the `games` table

Outcome: The application has real game data.

------------------------------------------------------------------------

# Stage 4 --- Games Pages

Build the main browsing experience.

Pages:

-   Games index
-   Game detail page

Outcome: Users can browse games and open game pages.

------------------------------------------------------------------------

# Stage 5 --- Follow System

Allow users to follow games.

Outcome: Users personalize their experience.

------------------------------------------------------------------------

# Stage 6 --- Patch Notes

Add patch pages for games.

Outcome: Users can read updates for a specific game.

------------------------------------------------------------------------

# Stage 7 --- Patch Summaries

Add simplified AI summaries.

Outcome: Updates become easier to understand.

------------------------------------------------------------------------

# Stage 8 --- Events

Display live events for games.

Outcome: Users see current or upcoming events.

------------------------------------------------------------------------

# Stage 9 --- Deployment

Deploy the application to **Heroku**.

Tasks:

-   Create Heroku app
-   Add Heroku Postgres
-   Configure environment variables
-   Deploy and test

Outcome: The project is publicly accessible.

------------------------------------------------------------------------

# Roadmap Philosophy

Because this is a short project:

• build the simplest working version first\
• improve later if time allows

Avoid polishing unfinished features.

------------------------------------------------------------------------

End of file
