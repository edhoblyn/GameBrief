# GameBrief — File Structure Guide

> Last updated: 2026-03-17

This document shows the actual file structure of the GameBrief Rails project.

---

## Root Project Structure

```text
GameBrief/
├── app/
├── bin/
├── config/
├── db/
├── Docs/
├── lib/
├── log/
├── public/
├── storage/
├── test/
├── tmp/
├── vendor/
├── Gemfile
├── Gemfile.lock
├── Procfile
└── README.md
```

---

## app/ Folder

```text
app/
├── controllers/
│   ├── application_controller.rb
│   ├── chats_controller.rb
│   ├── errors_controller.rb
│   ├── events_controller.rb
│   ├── favourites_controller.rb
│   ├── friendships_controller.rb
│   ├── games_controller.rb
│   ├── messages_controller.rb
│   ├── pages_controller.rb
│   ├── patches_controller.rb
│   ├── posts_controller.rb
│   ├── reminders_controller.rb
│   ├── users_controller.rb
│   ├── admin/
│   │   ├── base_controller.rb
│   │   ├── chat_histories_controller.rb
│   │   ├── dashboard_controller.rb
│   │   ├── event_imports_controller.rb
│   │   ├── patch_scrapes_controller.rb
│   │   └── users_controller.rb
│   └── users/
│       ├── omniauth_callbacks_controller.rb
│       └── registrations_controller.rb
├── models/
│   ├── application_record.rb
│   ├── chat.rb
│   ├── event.rb
│   ├── favourite.rb
│   ├── friendship.rb
│   ├── game.rb
│   ├── game_suggestion.rb
│   ├── message.rb
│   ├── patch.rb
│   ├── patch_summary.rb
│   ├── post.rb
│   ├── reminder.rb
│   └── user.rb
├── views/
│   ├── admin/dashboard/
│   ├── devise/ (standard Devise views)
│   ├── errors/
│   ├── events/
│   │   ├── index.html.erb
│   │   └── show.html.erb
│   ├── games/
│   │   ├── index.html.erb
│   │   └── show.html.erb
│   ├── layouts/
│   │   └── application.html.erb
│   ├── messages/
│   │   ├── _form.html.erb
│   │   └── _message.html.erb
│   ├── pages/
│   │   ├── find_friends.html.erb
│   │   ├── home.html.erb
│   │   ├── my_events.html.erb
│   │   ├── my_games.html.erb
│   │   ├── my_patches.html.erb
│   │   └── my_profile.html.erb
│   ├── patches/
│   │   ├── _notes.html.erb
│   │   ├── index.html.erb
│   │   └── show.html.erb
│   ├── shared/
│   │   ├── _flashes.html.erb
│   │   ├── _hover_gradient_nav.html.erb
│   │   └── _settings_menu.html.erb
│   └── users/
│       ├── index.html.erb
│       └── show.html.erb
├── services/
│   ├── igdb_client.rb
│   ├── summary_service.rb
│   ├── patch_presentation_service.rb
│   ├── patch_presentation_fallback_service.rb
│   ├── event_summary_service.rb
│   ├── patch_scrape_runner.rb
│   ├── event_import_runner.rb
│   ├── admin_patch_scrape_log_store.rb
│   ├── admin_event_import_log_store.rb
│   ├── scrapers/          (one file per game — 29 scrapers)
│   ├── patch_importers/   (one file per game)
│   ├── event_scrapers/    (one file per game — 13 scrapers)
│   └── event_importers/   (one file per game)
└── javascript/
    └── controllers/
        ├── chat_stream_controller.js
        ├── flash_controller.js
        ├── follow_sound_controller.js
        ├── hub_menu_controller.js
        ├── notification_toggles_controller.js
        ├── social_feed_controller.js
        ├── sound_toggle_controller.js
        ├── suggestion_reveal_controller.js
        ├── theme_controller.js
        └── unfollow_animation_controller.js
```

---

## config/ Folder

```text
config/
├── routes.rb
├── database.yml
├── recurring.yml       (Solid Queue recurring job definitions)
├── environments/
│   ├── development.rb
│   └── production.rb
└── initializers/
    └── devise.rb       (OmniAuth.config.full_host hardcoded here)
```

---

## db/ Folder

```text
db/
├── schema.rb
├── seeds.rb
└── migrate/
```

Schema version: `2026_03_16_110000`. 13 tables: users, games, favourites, patches, patch_summaries, events, reminders, chats, messages, friendships, posts, game_suggestions, and Active Storage tables.

---

## lib/ Folder

```text
lib/
└── tasks/
    ├── patches.rake    (scrape tasks: patches:scrape_all, patches:scrape_<game>)
    └── events.rake     (import tasks: events:import_all, events:import_<game>)
```

---

## Docs/ Folder

```text
Docs/
├── GameBrief_Demo_Script.md
├── GameBrief_Features_Built.md
├── GameBrief_Features_Planned.md
├── GameBrief_Team_Progress.md
├── Heroku_EU_Migration_Checklist.md
├── Planning/
│   └── GameBrief_File_Structure.md
└── Reference/
    ├── 1GameBrief_Architecture_Guide.md
    ├── 2GameBrief_Rails_Setup_Guide.md
    ├── 3GameBrief_Feature_Build_Guide.md
    ├── 4GameBrief_IGDB_Integration_Guide.md
    ├── 5GameBrief_Data_Import_Strategy.md
    ├── 6GameBrief_Routes_and_Controller_Map.md
    ├── 7GameBrief_DB_Schema_Reference.md
    ├── 8GameBrief_Deployment_Guide.md
    ├── 9GameBrief_AI_Summary_Workflow.md
    ├── 10GameBrief_Admin_Workflow_Guide.md
    └── 11GameBrief_Scraping_Guide.md
```

---

## External Services

| Service | Purpose | Credentials |
| --- | --- | --- |
| IGDB API | Game catalogue import | TWITCH_CLIENT_ID, TWITCH_CLIENT_SECRET |
| Google OAuth | User authentication | GOOGLE_OAUTH_CLIENT_ID, GOOGLE_OAUTH_CLIENT_SECRET |
| OpenAI (GPT-4o) | Patch presentation + chatbot | OPENAI_API_KEY |
| Anthropic (Claude) | Patch + event summaries | ANTHROPIC_API_KEY |
| Heroku Postgres | Production database | DATABASE_URL (auto-set) |
| Active Storage | Avatar + cover image uploads | local disk (production) |
