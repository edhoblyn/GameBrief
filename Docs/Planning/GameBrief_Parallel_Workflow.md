# GameBrief --- Parallel Team Workflow Guide

This document explains how the team can **work simultaneously on the
project** without causing merge conflicts or blocking each other.

GameBrief is a short **2‑week project**, so the goal is to move fast
while keeping the codebase stable.

------------------------------------------------------------------------

# Core Principle

The team should follow this workflow:

Shared skeleton → Feature ownership → Parallel development → Frequent
merges

This allows everyone to work at the same time while minimizing
conflicts.

------------------------------------------------------------------------

# Step 1 --- Create the Project Skeleton

Before splitting into feature work, the team should quickly agree on:

• Models and relationships\
• Routes naming conventions\
• Basic controller structure\
• File structure\
• Branch naming strategy

Then generate the initial skeleton.

Example skeleton files:

    app/models/
      user.rb
      game.rb
      patch.rb
      patch_summary.rb
      event.rb
      favourite.rb
      reminder.rb

    app/controllers/
      games_controller.rb
      patches_controller.rb
      events_controller.rb
      favourites_controller.rb
      reminders_controller.rb

    app/views/
      games/
      patches/
      events/

These files can initially contain minimal or empty code.

The goal is simply to **create the structure so teammates can build in
parallel.**

------------------------------------------------------------------------

# Step 2 --- Feature Ownership

Each team member should own a **specific feature area**.

This reduces the chance of editing the same files.

Recommended split for a 4‑person team:

### Person 1 --- Authentication + App Shell

Owns:

• Devise setup\
• Google OAuth\
• login/logout flow\
• navbar / layout\
• authentication helpers

Key files:

    app/controllers/application_controller.rb
    app/views/layouts/application.html.erb
    config/initializers/devise.rb

------------------------------------------------------------------------

### Person 2 --- Games + IGDB

Owns:

• Game model\
• IGDB API integration\
• games index page\
• games show page

Key files:

    app/models/game.rb
    app/controllers/games_controller.rb
    app/views/games/
    app/services/igdb_client.rb

------------------------------------------------------------------------

### Person 3 --- Patches + Summaries

Owns:

• Patch model\
• PatchSummary model\
• patch pages\
• summary display

Key files:

    app/models/patch.rb
    app/models/patch_summary.rb
    app/controllers/patches_controller.rb
    app/views/patches/

------------------------------------------------------------------------

### Person 4 --- Events + Favourites + Reminders

Owns:

• Event model\
• Favourite model\
• Reminder model\
• follow/unfollow features\
• event display

Key files:

    app/models/event.rb
    app/models/favourite.rb
    app/models/reminder.rb
    app/controllers/events_controller.rb
    app/controllers/favourites_controller.rb
    app/controllers/reminders_controller.rb

------------------------------------------------------------------------

# Step 3 --- Branch Strategy

Each developer should work in their own branch.

Example:

    feature/authentication
    feature/games-igdb
    feature/patches
    feature/events-reminders

Never develop directly on `master`.

------------------------------------------------------------------------

# Step 4 --- Avoid High‑Conflict Files

Some files cause frequent merge conflicts.

Be careful with:

    config/routes.rb
    app/views/layouts/application.html.erb
    db/schema.rb
    db/migrate/*

Coordinate changes to these files with the team.

------------------------------------------------------------------------

# Step 5 --- Merge Often

Small merges are safer than large merges.

Recommended workflow:

1.  Pull latest master
2.  Work on feature branch
3.  Commit small changes
4.  Open pull request
5.  Merge once tested

Frequent merging keeps the project stable.

------------------------------------------------------------------------

# Step 6 --- Test After Each Merge

After merging into master, verify:

• application boots\
• login works\
• pages load\
• no console errors

Fix problems immediately before continuing.

------------------------------------------------------------------------

# Important Rule

Do not spend too long polishing features before merging.

For a short project:

Working feature \> perfect feature

------------------------------------------------------------------------

# Summary

Successful parallel development requires:

• shared skeleton first\
• clear feature ownership\
• separate branches\
• frequent merges\
• simple architecture

Following this workflow allows the entire team to **develop
simultaneously without blocking each other.**

------------------------------------------------------------------------

End of file
