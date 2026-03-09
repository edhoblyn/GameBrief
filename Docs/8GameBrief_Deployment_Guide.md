# GameBrief — Deployment Guide

## Deployment Platform

GameBrief will be deployed on **Heroku**.

## Required Environment Variables

Set these in Heroku Config Vars:

- GOOGLE_CLIENT_ID
- GOOGLE_CLIENT_SECRET
- TWITCH_CLIENT_ID
- TWITCH_CLIENT_SECRET
- RAILS_MASTER_KEY

You may also add any future AI/API keys here if needed.

## Heroku Setup Steps

1. Push the project to GitHub
2. Create a new Heroku app
3. Add the Heroku Postgres add-on
4. Set all required Config Vars
5. Connect the Heroku app to the GitHub repository or deploy with Git
6. Run database migrations
7. Open the app and test key flows

## Database

Use **Heroku Postgres** for production.

After deployment, run:

```bash
heroku run rails db:migrate
```

If you need to seed data:

```bash
heroku run rails db:seed
```

## Google OAuth Notes

Because the app uses Google OAuth, make sure the production callback URL is added to the Google Cloud console.

Example pattern:

```text
https://your-heroku-app-name.herokuapp.com/users/auth/google_oauth2/callback
```

## IGDB / Twitch Notes

Make sure these exist in Heroku Config Vars:

- TWITCH_CLIENT_ID
- TWITCH_CLIENT_SECRET

Without them, the IGDB integration will fail.

## Pre-Launch Checklist

- [ ] Heroku app created
- [ ] Heroku Postgres attached
- [ ] Config Vars added
- [ ] `rails db:migrate` run in production
- [ ] Google OAuth production callback URL added
- [ ] App boots successfully
- [ ] Login works
- [ ] Games page loads
- [ ] IGDB integration works

## Post Deployment Checks

Verify:

- Google OAuth works
- Game list loads
- Patch pages display correctly
- Events display correctly
- No production errors appear in Heroku logs

Useful command:

```bash
heroku logs --tail
```
