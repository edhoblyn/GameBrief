# GameBrief — Architecture Guide

## Project Goal

GameBrief helps casual gamers understand live-service game updates quickly.

The app focuses on:
- games users care about
- patch notes
- AI summaries
- live events
- reminders

## Main Architecture

The application uses a simple Rails MVC structure.

### Core flow

1. User signs in with Google OAuth
2. User browses games imported from IGDB
3. User follows games
4. User opens a game page
5. User reads patch summaries and sees events
6. User creates reminders for events

## Data Sources

### Games
Games come from **IGDB**.

### Patches
Patch notes come from manual/admin input in the MVP.

### Events
Events come from manual/admin input in the MVP.

## Deployment

Production deployment target:
- **Heroku**

Production database:
- **Heroku Postgres**

## Architectural Principles

- Keep the app simple
- Use Rails conventions
- Avoid unnecessary services unless they clearly help
- Use IGDB only for game catalogue data
- Keep patch and event workflows separate from IGDB
