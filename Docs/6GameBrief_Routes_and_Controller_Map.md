# GameBrief --- Routes and Controller Map

## Routes Overview

  Route          Controller               Purpose
  -------------- ------------------------ -----------------------
  /              PagesController          Home page
  /games         GamesController#index    List games
  /games/:id     GamesController#show     Game detail page
  /patches/:id   PatchesController#show   Patch page
  /events/:id    EventsController#show    Event page
  /favourites    FavouritesController     Follow/unfollow games
  /reminders     RemindersController      Manage reminders

## Controller Responsibilities

### PagesController

Handles static pages such as homepage.

### GamesController

-   List games
-   Show game page
-   Display patches and events

### PatchesController

-   Show patch notes
-   Display AI summaries

### EventsController

-   Show event details
-   Event reminders

### FavouritesController

-   Follow games
-   Unfollow games

### RemindersController

-   Create reminder
-   Delete reminder

### OmniauthCallbacksController

Handles Google OAuth authentication.
