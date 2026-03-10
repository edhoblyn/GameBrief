# GameBrief — Rails Setup Guide

## 1. Create the Rails App

Create a new Rails project with PostgreSQL.

## 2. Add Gems

Core gems:
- devise
- omniauth
- omniauth-google-oauth2
- dotenv-rails

## 3. Authentication Setup

Use Devise with Google OAuth.

You will need:
- GOOGLE_CLIENT_ID
- GOOGLE_CLIENT_SECRET

## 4. IGDB Setup

You will also need:
- TWITCH_CLIENT_ID
- TWITCH_CLIENT_SECRET

Store these in `.env` locally.

## 5. Database

Use PostgreSQL locally and in production.

Production target:
- **Heroku Postgres**

## 6. Heroku Setup

Before deployment:

- create a Heroku app
- add Heroku Postgres
- set Config Vars
- make sure `RAILS_MASTER_KEY` is set
- update Google OAuth with the Heroku callback URL

## 7. Recommended Setup Order

1. Rails app
2. Devise
3. Google OAuth
4. Models and migrations
5. IGDB service
6. Core pages
7. Heroku deployment
