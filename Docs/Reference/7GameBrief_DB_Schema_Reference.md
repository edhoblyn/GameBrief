# GameBrief — Database Schema Reference

> Last updated: 2026-03-17
> Schema version: 2026_03_17_104151

## users

| Column | Type | Notes |
| --- | --- | --- |
| id | bigint | PK |
| email | string | unique, not null |
| encrypted_password | string | Devise |
| reset_password_token | string | unique |
| reset_password_sent_at | datetime | |
| remember_created_at | datetime | |
| provider | string | OmniAuth (Google) |
| uid | string | OmniAuth (Google) |
| username | string | |
| role | string | `"user"` or `"admin"`, default `"user"` |
| avatar_url | string | Active Storage reference |
| follower_count | integer | |
| created_at | datetime | |
| updated_at | datetime | |

Relationships: has_many favourites, games (through favourites), reminders, chats, friendships, posts, likes

---

## games

| Column | Type | Notes |
| --- | --- | --- |
| id | bigint | PK |
| name | string | unique (case-insensitive) |
| slug | string | unique |
| cover_image | string | IGDB cover URL |
| genre | string | e.g. `"Shooter"`, `"MOBA"` |
| free_to_play | boolean | default false |
| single_player | boolean | default false |
| multiplayer | boolean | default false |
| created_at | datetime | |
| updated_at | datetime | |

Relationships: has_many patches, events, favourites

---

## patches

| Column | Type | Notes |
| --- | --- | --- |
| id | bigint | PK |
| game_id | bigint | FK → games |
| title | string | |
| content | text | raw scraped or manual patch text |
| source_url | string | de-duplication key |
| published_at | datetime | indexed; used for sorting and freshness badges |
| formatted_content | text | markdown/HTML formatted version |
| structured_sections | jsonb | AI-generated structured sections; default `[]` |
| ai_presentation_requested_at | datetime | tracks async generation state |
| ai_presentation_generated_at | datetime | set when generation completes |
| ai_presentation_error | text | error message if generation failed |
| created_at | datetime | |
| updated_at | datetime | |

Relationships: belongs_to game, has_many patch_summaries, has_many chats

---

## patch_summaries

| Column | Type | Notes |
| --- | --- | --- |
| id | bigint | PK |
| patch_id | bigint | FK → patches |
| summary | text | generated text |
| summary_type | string | `"quick_summary"`, `"casual_impact"`, or `"should_i_log_in"` |
| created_at | datetime | |
| updated_at | datetime | |

Relationships: belongs_to patch

---

## events

| Column | Type | Notes |
| --- | --- | --- |
| id | bigint | PK |
| game_id | bigint | FK → games |
| title | string | |
| description | text | |
| start_date | datetime | nil = ongoing/active now |
| summary | text | one-sentence AI summary |
| summary_requested_at | datetime | tracks generation state and provider cooldown |
| created_at | datetime | |
| updated_at | datetime | |

Relationships: belongs_to game, has_many reminders

---

## reminders

| Column | Type | Notes |
| --- | --- | --- |
| id | bigint | PK |
| user_id | bigint | FK → users |
| event_id | bigint | FK → events |
| created_at | datetime | |
| updated_at | datetime | |

Relationships: belongs_to user, belongs_to event

---

## favourites

| Column | Type | Notes |
| --- | --- | --- |
| id | bigint | PK |
| user_id | bigint | FK → users |
| game_id | bigint | FK → games |
| created_at | datetime | |
| updated_at | datetime | |

Relationships: belongs_to user, belongs_to game

---

## chats

| Column | Type | Notes |
| --- | --- | --- |
| id | bigint | PK |
| user_id | bigint | FK → users |
| patch_id | bigint | FK → patches |
| title | string | auto-generated from first message |
| created_at | datetime | |
| updated_at | datetime | |

Relationships: belongs_to user, belongs_to patch, has_many messages

One chat per user per patch. Message limit: 5 user messages per chat.

---

## messages

| Column | Type | Notes |
| --- | --- | --- |
| id | bigint | PK |
| chat_id | bigint | FK → chats |
| content | text | |
| role | string | `"user"` or `"assistant"` |
| created_at | datetime | |
| updated_at | datetime | |

Relationships: belongs_to chat

---

## friendships

| Column | Type | Notes |
| --- | --- | --- |
| id | bigint | PK |
| user_id | bigint | FK → users |
| friend_id | bigint | FK → users |
| created_at | datetime | |
| updated_at | datetime | |

Unique index on `[user_id, friend_id]`. Bidirectional: adding a friend creates a record in both directions.

Relationships: belongs_to user, belongs_to friend (User)

---

## posts

| Column | Type | Notes |
| --- | --- | --- |
| id | bigint | PK |
| user_id | bigint | FK → users |
| body | text | |
| created_at | datetime | |
| updated_at | datetime | |

Relationships: belongs_to user, has_many likes

---

## likes

| Column | Type | Notes |
| --- | --- | --- |
| id | bigint | PK |
| user_id | bigint | FK → users |
| post_id | bigint | FK → posts |
| created_at | datetime | |
| updated_at | datetime | |

Unique index on `[user_id, post_id]`. One like per user per post.

Relationships: belongs_to user, belongs_to post

---

## game_suggestions

| Column | Type | Notes |
| --- | --- | --- |
| id | bigint | PK |
| name | string | not null |
| created_at | datetime | |
| updated_at | datetime | |

---

## active_storage_attachments / active_storage_blobs / active_storage_variant_records

Standard Rails Active Storage tables. Used for user avatar and cover image uploads.
