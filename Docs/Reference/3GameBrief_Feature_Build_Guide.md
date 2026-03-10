# GameBrief — Feature Build Guide

## MVP Features

### 1. Authentication
- Google login with Devise + OmniAuth

### 2. Games
- import games from IGDB
- show games index
- show game page

### 3. Favourites
- follow games
- unfollow games

### 4. Patches
- create patches manually in MVP
- display patch pages
- store raw patch content

### 5. Patch Summaries
- store AI-generated summaries
- show quick summaries for casual gamers

### 6. Events
- create live events manually in MVP
- display events on game pages

### 7. Reminders
- allow users to save reminders

## Recommended Build Order

1. Authentication
2. Game model + IGDB import
3. Games pages
4. Favourites
5. Patches
6. Patch summaries
7. Events
8. Reminders
9. Heroku deployment

## Production Notes

When deploying to **Heroku**:
- add all Config Vars
- run migrations
- verify OAuth callback URLs
- test IGDB in production
