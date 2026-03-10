# GameBrief --- AI Master Context (2‑Week Project Version)

This document provides **core context** for AI assistants helping build
GameBrief.

Important constraint: This is a **short 2‑week student project**, so
development should prioritize **simplicity, clarity, and a working
demo** over advanced architecture.

Avoid overengineering. Prefer simple Rails patterns.

------------------------------------------------------------------------

# Project Goal

GameBrief helps **casual gamers understand game updates quickly**.

Instead of reading long patch notes, users see:

• short AI summaries\
• key gameplay impacts\
• live events for games they follow

Goal:

> A user should understand what changed in their game in under one
> minute.

------------------------------------------------------------------------

# Key Product Idea

Casual players often **skip long patch notes**.

GameBrief solves this by transforming updates into **quick readable
summaries**.

------------------------------------------------------------------------

# Core Features (MVP Scope)

Only these features are required for the project demo:

1.  Google OAuth login
2.  Games list page
3.  Game detail page
4.  Ability to follow games
5.  Patch notes page
6.  AI patch summaries
7.  Basic event listing

Everything else is optional.

------------------------------------------------------------------------

# Tech Stack

Backend - Ruby on Rails - PostgreSQL

Authentication - Devise - OmniAuth - Google OAuth

External Data - IGDB API (game catalogue)

Deployment - Heroku

Frontend - Rails ERB views

------------------------------------------------------------------------

# Data Sources

## Games

Games are imported from **IGDB API**.

Used fields: - name - slug - cover image

## Patch Notes

For the MVP these can be **entered manually**.

Automation is not required.

## Events

Events can also be **entered manually**.

------------------------------------------------------------------------

# Database Models

User\
Game\
Favourite\
Patch\
PatchSummary\
Event\
Reminder

Associations follow standard Rails conventions.

------------------------------------------------------------------------

# Deployment

Production environment: **Heroku**

Database: **Heroku Postgres**

Environment variables required:

GOOGLE_OAUTH_CLIENT_ID\
GOOGLE_OAUTH_CLIENT_SECRET\
TWITCH_CLIENT_ID\
TWITCH_CLIENT_SECRET\
RAILS_MASTER_KEY

------------------------------------------------------------------------

# Development Rules

Because this is a short project:

• Follow Rails conventions\
• Avoid complex architecture\
• Prefer manual workflows over automation\
• Focus on delivering a working demo

------------------------------------------------------------------------

# How AI Should Help

When assisting with GameBrief:

• Generate simple Rails code\
• Use MVC patterns\
• Avoid unnecessary abstractions\
• Assume Heroku deployment

The goal is **speed and clarity**, not perfection.

------------------------------------------------------------------------

End of file
