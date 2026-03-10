# GameBrief --- File Structure Guide

This document shows the **expected file structure** for the GameBrief
Rails project. It helps teammates quickly understand where different
parts of the application live.

The structure follows **standard Rails conventions** so that the project
remains simple and easy to maintain.

------------------------------------------------------------------------

# Root Project Structure

Typical project layout:

    GameBrief/
    ├── app/
    ├── bin/
    ├── config/
    ├── db/
    ├── lib/
    ├── log/
    ├── public/
    ├── storage/
    ├── test/
    ├── tmp/
    ├── vendor/
    ├── docs/
    ├── Gemfile
    ├── Gemfile.lock
    ├── Procfile
    ├── README.md

------------------------------------------------------------------------

# docs/ Folder

This folder contains **project documentation**.

    docs/
    ├── GameBrief_AI_Master_Context.md
    ├── GameBrief_Project_Roadmap.md
    ├── GameBrief_Project_TODO.md
    ├── GameBrief_File_Structure.md

These files help teammates and AI assistants understand the project.

------------------------------------------------------------------------

# app/ Folder

Most of the application code lives here.

    app/
    ├── controllers/
    ├── models/
    ├── views/
    ├── helpers/
    ├── services/
    ├── assets/

------------------------------------------------------------------------

# Controllers

Controllers handle incoming web requests.

Expected controllers:

    app/controllers/

    application_controller.rb
    pages_controller.rb
    games_controller.rb
    patches_controller.rb
    events_controller.rb
    favourites_controller.rb
    reminders_controller.rb
    omniauth_callbacks_controller.rb

Responsibilities:

PagesController - homepage

GamesController - games index - game show page

PatchesController - patch notes page - display AI summaries

EventsController - event details

FavouritesController - follow/unfollow games

RemindersController - create/delete reminders

OmniauthCallbacksController - Google OAuth login

------------------------------------------------------------------------

# Models

Models represent database tables.

    app/models/

    user.rb
    game.rb
    favourite.rb
    patch.rb
    patch_summary.rb
    event.rb
    reminder.rb

Relationships overview:

User - has_many favourites - has_many games through favourites -
has_many reminders

Game - has_many patches - has_many events

Patch - belongs_to game - has_many patch_summaries

Event - belongs_to game - has_many reminders

------------------------------------------------------------------------

# Views

Views contain the HTML templates.

    app/views/

    pages/
    games/
    patches/
    events/
    favourites/
    reminders/

Example:

    app/views/games/
    index.html.erb
    show.html.erb

------------------------------------------------------------------------

# Services

Service objects contain external integrations.

    app/services/

    igdb_client.rb

This file handles:

-   IGDB API requests
-   Twitch authentication
-   importing game data

------------------------------------------------------------------------

# Config Folder

Important configuration files:

    config/

    routes.rb
    database.yml
    environment.rb
    environments/
    initializers/

Key file:

routes.rb --- defines all application routes.

Example routes:

    /games
    /games/:id
    /patches/:id
    /events/:id

------------------------------------------------------------------------

# Database

Database structure and migrations.

    db/

    schema.rb
    seeds.rb
    migrate/

Important commands:

    rails db:migrate
    rails db:seed

------------------------------------------------------------------------

# Procfile (Heroku)

Heroku uses a Procfile to start the Rails server.

Example:

    web: bundle exec rails server -p $PORT

------------------------------------------------------------------------

# Services & APIs

External services used:

IGDB API\
Google OAuth\
Heroku Postgres

Environment variables:

    GOOGLE_OAUTH_CLIENT_ID
    GOOGLE_OAUTH_CLIENT_SECRET
    TWITCH_CLIENT_ID
    TWITCH_CLIENT_SECRET
    RAILS_MASTER_KEY

------------------------------------------------------------------------

# Development Rule

Always follow **Rails conventions**:

Controllers → `app/controllers`\
Models → `app/models`\
Views → `app/views`

Avoid creating unnecessary folders unless needed.

Keeping the structure predictable makes the project much easier for
teammates and AI assistants to work with.

------------------------------------------------------------------------

# End of File
