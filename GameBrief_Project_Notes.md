# GameBrief Project Notes

**Purpose:** evidence-based CV and interview notes for Edward Hoblyn  
**Repository reviewed:** complete working tree and all locally available Git refs/history  
**Git identity matched:** `edhoblyn <edhoblyn@gmail.com>`  
**Project period in Git:** 9–19 March 2026 (11 calendar days, consistent with the stated approximately two-week Le Wagon main-project sprint)  
**Prepared:** 19 October 2026

## Executive summary

GameBrief is a full-stack Ruby on Rails web application for casual gamers who want to understand live-service games without reading long patch notes or visiting many publisher sites. Users can browse and follow games, see imported patch notes and upcoming events, request or view AI-generated explanations, ask questions about a patch in a contextual chatbot, save event reminders, and use social/profile features.

This was clearly a four-person team project. Git contains work by Edward Hoblyn, Hortense Fievet, Baptiste Sardou and Bianca Correia, plus Dependabot. The initial Rails application also came from a Le Wagon template. Therefore, the existence of a feature is not by itself evidence that Edward built it.

The history nevertheless supports a substantial and unusually broad personal contribution by Edward. The strongest defensible ownership claims are:

- establishing the first domain models/migrations and the initial IGDB-backed game catalogue;
- building and expanding the patch/event ingestion architecture, including source-specific scrapers, importers, runners, Rake tasks, jobs, date normalisation, deduplication and failure handling;
- implementing much of the games/events discovery experience, filters, sorting and responsive UI;
- creating the AI patch-presentation pipeline and its fallback, job, data fields, polling UI and tests;
- building admin operations for ingestion, logs, roles and background “run all” jobs;
- substantial profile/social enhancements, including friend-request flows, public-profile work and Turbo Stream feed broadcasting;
- repeated Heroku/PostgreSQL/OAuth/Cloudinary deployment and production-debugging work; and
- coordinating a high-frequency branch-and-pull-request workflow and maintaining planning/demo documentation.

Git attributes 639 commits to Edward's identity, but 281 are merges. The more meaningful implementation figure is **358 non-merge commits** out of 469 non-merge commits in the available history. The report uses those implementation commits, file diffs and current `git blame` evidence—not the headline 639 figure alone—to support ownership claims.

## 1. Method and evidential limits

### Sources examined

- the complete current repository: models, migrations/schema, controllers, services, jobs, views, Stimulus controllers, stylesheets, tests, configuration, Rake tasks and project documentation;
- all available refs and the full `git log --all`, including branch and merge history;
- `git shortlog`, author/email filtering, non-merge commit counts, commit diffs and file-frequency analysis;
- `git blame` on major current files and aggregated blame for scraper/importer/job/test directories; and
- the current Rails test suite.

### Attribution standard

- **Strongly supported:** a non-merge commit under Edward's identity introduces or substantially changes the feature, normally with current blame or follow-up commits supporting continued ownership.
- **Substantial contribution:** another person introduced the feature, but Edward made material, identifiable additions or redesigns.
- **Team/uncertain:** the feature exists, but another author introduced it, ownership is mixed, or Git cannot distinguish pair work.

Git records the author identity used for a commit; it cannot prove who typed every line, whether work was paired, or whether tools assisted it. Merge authorship proves integration activity, not authorship of the merged branch. The local repository preserves PR numbers and branch names in merge subjects, but not GitHub review discussions or issue conversations.

### Repository health caveat

The repository contains 97 test files. A full run executed **281 tests and 1,209 assertions**, but the current checkout is not green: **13 failures and 5 errors**. Examples include removed route helpers still referenced by tests, a removed `ff7_rebirth` runner configuration still expected by a test, stale UI assertions and a date-normalisation expectation. It is fair to say the project has a substantial Minitest suite and that Edward wrote many tests; it is not fair to say all tests currently pass or that the application is production-hardened.

## 2. Project overview

### What GameBrief is and the problem it solves

Live-service game information is fragmented across publisher sites, long patch notes, esports calendars and community posts. GameBrief brings a player's selected games into one product and converts dense update information into a quicker, more personalised experience.

The product proposition is: follow the games you care about, see their latest changes and upcoming events, and use concise AI-assisted presentation or a patch-aware chatbot instead of reading every raw source page.

### Main user journey

1. A visitor lands on the video-led home page and can browse games publicly.
2. A user signs up with Devise email/password or signs in through Google OAuth.
3. They search/filter the game catalogue and follow selected games.
4. A game page shows its newest patch notes, future events and follower state.
5. A patch page presents raw or structured notes, stored summary options and a patch-context chatbot.
6. An event page shows timing, status/countdown, related content and reminder controls.
7. The Gaming Hub/profile brings together followed games, patches, reminders, friends and posts.
8. Admin users can trigger and diagnose patch/event imports and reset demo data.

### Main features present in the team project

- game catalogue sourced initially through IGDB/Twitch credentials;
- game search, genre/free-to-play/single-player/multiplayer filters and sorting;
- follow/unfollow and a personalised library;
- patch indexing, date/game filters, sorting and detailed notes;
- source-specific patch scraping/importing for many games, with manual/blocked-source states;
- events imported from publisher/community/Steam-like sources, plus reminders and calendar links;
- three stored patch-summary modes and short event summaries through Anthropic;
- GPT-powered patch-note restructuring and patch-context chat through RubyLLM;
- profile uploads, bios, public profiles, friendships/requests, posts and likes;
- Turbo/Stimulus interactions, SSE chatbot streaming and Turbo Stream social-feed updates;
- role-protected admin operations and diagnostic logs; and
- Heroku, PostgreSQL and Cloudinary production configuration.

### Evidence that it was a team project

Four human contributor identities appear throughout the same 11-day development window:

- Edward Hoblyn / `edhoblyn@gmail.com`: 639 commits, including 358 non-merges;
- Hortense identities: 65 commits in total (45 non-merges under the main email);
- Baptiste identities: 52 commits in total (34 non-merges under the main email); and
- Bianca identities: 51 commits in total (28 non-merges under the main email).

The history contains **304 “Merge pull request” commits** through PR #314. Those PRs merge branches such as `feature/games-igdb`, `patches`, `events-favorites`, `add-google-sign-in`, `socials`, `profileposts`, `feed` and numerous fix/polish branches. Team-authored examples include Hortense's first patch work (`08066e8`), Bianca's Google OAuth (`8715ecb`), Baptiste's event-summary service (`d4aea99`) and Hortense's initial post model/controller (`ded68a2`). The footer also names and links all four contributors.

## 3. Technical stack

### Languages and application framework

- Ruby 3.3.5 in the local environment;
- Rails 8.1.2 using conventional MVC, Active Record, Active Job, Active Storage and Action Cable/Turbo Streams;
- JavaScript through import maps and Stimulus controllers;
- ERB templates, HTML and extensive SCSS/CSS.

### Database and persistence

- PostgreSQL through the `pg` gem;
- Active Record migrations, foreign keys and indexes;
- JSONB for structured patch-note sections;
- Active Storage for avatar and cover uploads;
- Cloudinary as the configured production Active Storage service;
- Rails cache for temporary per-admin import logs.

### Front end

- server-rendered ERB;
- Bootstrap 5 and Simple Form;
- Sass/SCSS, Autoprefixer and Font Awesome;
- Hotwire Turbo and Stimulus;
- Redcarpet/Markdown rendering and `marked` in the streaming chat UI;
- responsive layouts, custom navigation, selectable visual themes, modals, toasts, animations and local-storage preferences.

### APIs and external services

- IGDB API for game metadata and covers, authenticated through Twitch OAuth client credentials;
- numerous official publisher/news pages and selected community/esports sources parsed with Nokogiri/open-uri;
- Steam/community feeds used by several game-specific importers;
- Anthropic API for stored patch summaries, event summaries and bio moderation;
- OpenAI GPT models through RubyLLM for structured patch presentation and contextual chat;
- Google OAuth through OmniAuth;
- Cloudinary for persistent uploaded media;
- optional SMTP configuration for mail and a game-suggestion mailer.

### Authentication and authorisation

- Devise database authentication, registration, password recovery and remember-me;
- Google OAuth via `omniauth-google-oauth2` and CSRF protection;
- authentication required globally with selected public actions for home/game/profile surfaces;
- user/admin role stored in the database;
- admin namespace guarded by `current_user.admin?`;
- controls to promote/demote admins and prevent removal of the last admin.

### Hosting and deployment

- Heroku remotes for the original and EU applications; current configuration and docs target `gamebrief-eu` and `gamebrief.live`;
- Heroku Postgres via `DATABASE_URL`;
- Puma web process in `Procfile`;
- Cloudinary storage in production;
- HTTPS-aware mailer/controller URL generation;
- imports designed to run by Rake/Heroku Scheduler, while production Active Job uses the in-process async adapter;
- Solid Queue/Cache/Cable gems and schemas are present, but the current production configuration deliberately does not run a Solid Queue supervisor.

### Testing and developer tooling

- Minitest model/controller/service/job coverage, including scraper and runner tests;
- Capybara and Selenium dependencies for system testing;
- RuboCop Rails Omakase, Brakeman and Bundler Audit tooling;
- Rails health route, Dockerfile, Kamal/Thruster scaffolding and CI configuration inherited or retained from Rails/template setup.

## 4. Technical implementation

### Important data model and relationships

- `User` has many `Favourite` records and therefore many followed `Game` records.
- `Game` has many `Patch` and `Event` records.
- `Patch` has many typed `PatchSummary` records and many per-user `Chat` records.
- `Chat` has many persisted user/assistant `Message` records, with a five-user-message limit.
- `User` has many `Reminder` records for `Event` objects.
- `Friendship` is a directed self-reference on `User`; accepted relationships are represented in both directions, while pending requests initially use one row.
- `User` has many `Post` and `Like` records; a composite unique index prevents duplicate likes.
- Active Storage attachments provide uploaded avatar/cover media.

The schema contains sensible uniqueness and lookup indexes: unique user email, game slug, case-normalised game name, friendship pair, user/post like pair, and patch publication date. Foreign keys cover the core relations. Some join models such as favourites/reminders do not have composite uniqueness constraints, so duplicate-prevention relies more on controller behavior than database enforcement.

### Controllers and query logic

The application uses conventional Rails controllers with richer filtering logic:

- `GamesController` composes model scopes for query, genre, price model and player modes, and can sort by name or follower count.
- `PatchesController` supports nested/global lists, date/game filters and a “recommended” sort that prioritises followed games.
- `EventsController` filters upcoming events by time range and multiple games, groups results into human-readable timeline sections and computes detail-page status/countdown data.
- profile/social controllers handle search, friend-request state, feeds, posts and likes.
- the admin namespace separates authorisation and operational ingestion actions from public controllers.

### Ingestion architecture

Patch/event ingestion is one of the most technically distinctive areas. The design separates responsibilities:

1. source-specific **scrapers** fetch and parse external HTML/API responses;
2. source-specific **importers** locate a game, normalise records and create/update/skip data;
3. central **runner registries** map source keys to labels, importer classes, game slugs and whether manual triggering is safe;
4. **Rake tasks**, individual jobs and “run all” jobs provide scheduled/operational entry points;
5. **admin controllers and log stores** expose results and partial failures to an admin;
6. tests stub source results and assert import/deduplication behavior.

The current tree contains 31 patch scraper files, 30 patch importer files, 19 event scraper files and 19 event importer files. The active runner registry exposes 29 patch sources and 19 event sources. Counts differ because some files/configurations were removed or disabled during the sprint, which also explains one current stale test.

Notable engineering details include source URL deduplication, alternative game slugs, preserving real imported data during seeding, future-date rejection/inference, publication-date extraction across inconsistent sites, continuing a run after one source fails, distinguishing blocked/API/manual sources, and replacing event sets only after a source returns data.

### AI/LLM implementation

There are four distinct AI uses, with different ownership:

- stored patch summaries (quick summary, casual impact and “should I log in?”) use Anthropic;
- short event summaries use Anthropic and run through Active Job, with a temporary provider cooldown for low-credit failures;
- AI patch presentation asks GPT-4o-mini for strict JSON, validates and normalises the response, stores a Markdown introduction plus JSONB sections, and falls back to deterministic text parsing when needed;
- patch chat injects the current patch content into instructions, replays persisted history and streams GPT-4o response tokens to the browser using server-sent events.

The patch-presentation logic is particularly interview-worthy: it detects long/unstructured “wall of text” notes, tracks requested/generated/error state, rejects invalid JSON/no-section responses, avoids inventing facts through prompting, and has a non-AI fallback so presentation does not depend completely on provider availability.

### Real-time and asynchronous behavior

- patch-chat tokens stream over `ActionController::Live::SSE` and are rendered incrementally by a Stimulus controller;
- new social posts are broadcast to the author and friends using Turbo Streams over Action Cable;
- AI event summaries and patch presentation can be queued through Active Job;
- admin “run all” ingestion actions leave the request cycle and record cached diagnostics;
- the production queue adapter is currently `:async`, so these jobs are asynchronous within the web process rather than backed by a durable production queue.

### Responsive/product UI

The app contains custom, gaming-oriented visual design rather than stock Rails pages: poster grids, compact patch/event cards, timeline groupings, themed settings, profile panels/modals, follow animations, toast feedback, sticky AI chat, mobile breakpoints and accessibility-oriented labels. The Stimulus layer handles theme and sound preferences, event/profile modals, chat streaming, flash behavior, notification-toggle mock state and social interactions.

## 5. Edward Hoblyn's personal contribution

### Commit-level overview

- 639 commits match `edhoblyn <edhoblyn@gmail.com>` across all available refs.
- 358 are non-merge implementation/documentation commits; 281 are merges.
- Edward authored 265 PR merge commits. This strongly supports a coordination/integration role, but those merges are not counted as personal implementation of teammates' code.
- His non-merge commits occur on every day from 9 to 19 March, with the heaviest days on 12 and 16 March.
- Current blame attributes all lines in the patch runner (339), event runner (199), games controller (75), admin dashboard controller (63), scraper/importer directories and almost all current tests to Edward's Git identity. These figures support sustained ownership of those areas but should not be turned into a simplistic “percentage of the whole app” claim.

### A. Foundation, database design and initial catalogue — strongly supported

Edward created the repository from the Le Wagon Devise template (`d0b25ea`), then added the first domain model/migration set for games, favourites, patches, patch summaries, events and reminders (`51e4cdd`, 23 files/153 insertions). He repaired the initial schema/migration state (`0b56c48`) and created the first game views and seed data (`581e840`, `ad5e7c6`).

He then introduced the initial working IGDB client integration and updated game views/seeding (`bf37fea`, 5 files/71 additions). Current `igdb_client.rb` still obtains a Twitch client-credentials token and queries IGDB for name, slug and cover URL.

**Defensible wording:** “Established the initial Rails domain model and IGDB-backed game catalogue.”  
**Caveat:** do not say he built authentication from scratch; Devise arrived with the Le Wagon template, and Bianca implemented Google OAuth.

### B. Game discovery and filtering — strongly supported

Edward added game search (`7213d3a`), genre filtering/sorting/footer/lazy image loading (`41cd654`), changed the schema to multi-genre support (`e8dc1cc`), later added free-to-play filtering (`fe1cc4f`), toggleable filters (`edd440d`), single/multiplayer fields and filters with migration/tests (`9a12be8`), and clear-search behavior (`a48137c`).

Current blame assigns all 75 lines of `GamesController` to Edward and 75 of 128 current game-index view lines to him, with the remaining view work attributable mainly to Hortense and Baptiste. His commits span controllers, scopes/models, migrations, views, SCSS and controller/model tests.

**Defensible wording:** “Implemented the catalogue's search, multi-criteria filters and sorting across Active Record queries, migrations and responsive UI.”

### C. Patch and event ingestion pipelines — strongest personal ownership

Edward introduced the first Marvel Rivals scraper and source URL field (`0ed6da8`), then its importer, scheduled job and tests (`5d95e29`). He repeated and generalised the pattern across Warzone (`115edc7`), Fortnite, Apex Legends, Helldivers 2, Destiny 2, Minecraft, Valorant, Roblox, Clash Royale, Clash of Clans, EA Sports FC and many later sources.

He replaced repeated tasks with a shared runner and admin entry point (`9f4ee5a`, 7 files/269 additions), made run-all resilient to individual source failures (`d7bd47e`), and added publication dates/filtering across 39 files (`0ecbe7d`). Follow-up commits corrected source-specific dates, future dates and undated ordering (`9b99ac7`, `7f4d8cd`, `e1add57`, `ab87bb1`). On 16 March, a series of Edward-authored source commits expanded both patch and event coverage; `6885934` added the parallel event runner/admin/job/log architecture.

Current blame is unusually conclusive:

- 2,908 current lines under `app/services/scrapers`: Edward;
- 1,446 current lines under `app/services/patch_importers`: Edward;
- 2,259 current lines under `app/services/event_scrapers`: Edward;
- 809 current lines under `app/services/event_importers`: Edward;
- all 339 current lines of `PatchScrapeRunner`: Edward;
- all 199 current lines of `EventImportRunner`: Edward; and
- all 337 current lines across job files: Edward.

**Defensible wording:** “Designed and implemented the project's multi-source patch/event ingestion and orchestration layer.”  
**Caveat:** say “multi-source” or quote the active 29 patch/19 event registry counts; do not imply every source is currently reliable. Several are deliberately disabled/manual because of bot protection or poor source data, and one stale source test currently fails.

### D. Patch browsing, date reliability and readable presentation — strongly supported

Edward implemented publication dates, date filters and robust ordering (`0ecbe7d`), newer/older sort behavior, followed-game recommendation ordering, fresh badges (`f3e8790`), game-page patch filters (`1b740d4`), readable Markdown presentation (`d74c6d7`) and source-aware navigation (`ad56316`). Current blame attributes 79 of 101 lines of `PatchesController` and 242 of 244 lines of the large `Patch` model to Edward; the remaining controller lines come from Baptiste and Bianca.

This work dealt with a real data-quality problem: source pages expose inconsistent or missing dates. The model contains normalisation, URL inference, future-date rejection, known/unknown ordering and deterministic demo fallbacks.

### E. AI patch presentation — strongly supported; chatbot ownership is shared

Edward's `beb83f9` commit created the AI-formatted patch-note presentation as a coherent vertical slice: migration, model state, service, background job, Stimulus polling controller, partial/view changes and tests (19 files/718 additions). Current blame assigns all of `PatchPresentationService` and `PatchPresentationFallbackService` to Edward.

He also built the current chat-stream Stimulus client in `4928ba6` and refined Markdown rendering/sticky behavior in `e0d400b`; current blame gives Edward 241 of 242 lines in `chat_stream_controller.js`. He added message-count behavior and fixed history type and Heroku import-map issues (`6476b13`, `87a5458`, `0a9b818`).

However, Bianca introduced the core chat/message models and controllers (`c073def`) and the original SSE-capable backend in `8469ea1`; current blame gives Bianca 74 of 81 lines in `ChatsController`, 56 of 65 in `MessagesController`, and most of the `Chat`/`Message` models. Therefore:

- **Supported:** Edward implemented the AI patch-presentation pipeline and substantially contributed the streaming browser client and chatbot UX/reliability.
- **Not supported:** Edward single-handedly built the whole patch chatbot.

The original stored `SummaryService` belongs to Baptiste in current blame, and Hortense introduced early patch/summary screens. Edward should describe his patch-presentation work separately from the team's stored summary feature.

### F. Event AI flow — substantial contribution, not original ownership

Baptiste introduced `EventSummaryService` and the first button-driven summary flow in `d4aea99`. Edward later replaced it with an automatic background flow (`adcd354`), adding model callbacks/state, an Active Job, migration and tests. He added low-credit failure cooldown/handling in `3b62140`. Current service blame is mixed: 59 lines Edward and 22 Baptiste.

**Defensible wording:** “Converted the team's event-summary feature into a background, failure-aware workflow.”  
**Not defensible:** “Created the event AI summary feature alone.”

### G. Admin tools and asynchronous operations — strongly supported

Edward added roles and a manual scrape trigger (`4c906cb`), then a dedicated admin panel with scrape logs and admin management (`38ea435`, 14 files/423 additions). He added controls for blocked sources, moved run-all scraping off the request cycle (`8f8c349`), mirrored the design for events (`6885934`), added chat-history clearing and a repeatable demo reset.

Current blame assigns all of `Admin::DashboardController` and both central runner files to Edward. The feature commits include controller/model tests and job tests.

### H. Profile, social and responsive front end — substantial and often strong, but shared

Edward created early dedicated My Games/My Patches/My Events destinations (`ef9e306`, `72e33f0`, `0c16831`), notification-toggle UI (`63634db`, `bc7eeaa`), a broad mobile pass (`2e51735`) and many later profile panels and polish commits. Some standalone routes were subsequently consolidated into the large profile page, so CV wording should focus on the personalised hub rather than claim all old pages remain unchanged.

He added public-profile functionality (`72143ec`), transformed simple friendship behavior into a pending accept/decline request flow (`6dd0bd5`), improved modal/search/live request UX, and added real-time feed broadcasts with Turbo Streams (`75e4dd8`) plus an Active Storage URL fix (`392b5da`). He also added editable bios with validation, a character-count Stimulus controller and Anthropic moderation (`86bbebf`).

Ownership remains shared:

- Baptiste created early social/chat functionality and substantial profile styling;
- Hortense introduced the first friendship/find-friends implementation and the post model/controller;
- Bianca contributed dashboard/profile/chat presentation and likes-related work;
- Edward extended and integrated these areas significantly.

Current blame illustrates that blend: Edward owns 931 of 1,443 current `my_profile.html.erb` lines, while Hortense owns 371 and Baptiste 140; Edward owns 29 of 42 current friendship-controller lines, while Hortense owns 13.

**Defensible wording:** “Substantially developed the personalised profile/social experience, including request-based friendships, public profile UI and Turbo Stream feed updates.”  
**Not defensible:** “Created the entire social network.”

### I. Deployment, hosting and production debugging — strongly supported

Edward configured PostgreSQL production use through `DATABASE_URL` (`3fe2eb5`), simplified Heroku adapters (`49295f0`), fixed Google OAuth CSRF/callback HTTPS/custom-domain issues (`dc749b0`, `4029078`, `4ec35a8`, `e19a675`), iterated on Heroku queue/scheduler behavior (`97b990b`, `78f1b28`, `9f4ee5a`), set the production mailer host (`8982e23`), added Cloudinary (`8677a15`) and corrected production streaming/import-map and Active Storage URL issues (`0a9b818`, `392b5da`).

Current blame attributes all 97 lines of `config/environments/production.rb` to Edward. Git remotes and documentation confirm deployment to Heroku, including an EU migration and `gamebrief.live` configuration.

**Defensible wording:** “Deployed and debugged the Rails/PostgreSQL app on Heroku, including OAuth callback, scheduler/job, custom-domain and Cloudinary configuration.”  
**Caveat:** avoid claiming a durable background-job architecture: production currently uses the in-process async adapter.

### J. Testing, debugging, refactoring and product coordination — strongly supported

Edward's feature commits repeatedly add model/controller/service/job tests. Aggregated current blame attributes 8,029 test lines to Edward and 11 to Bianca. Examples include scraper/importer behavior, date handling, admin authorisation, run-all jobs, AI presentation validation and game filters. The suite's current failures must still be acknowledged.

His debugging commits include nil-current-user/nav guards, Heroku rollout guards for new columns, scrape-all failure isolation, date/source corrections, sticky UI fixes, AI chat history/streaming fixes, broken ERB fixes, poster/image fixes and Action Cable/Active Storage URL fixes. `7ff42ca` removed dead UI code and consolidated shared controller helpers.

Edward also maintained the team task/progress/feature/checklist/demo documents and authored most PR merges. This supports saying he coordinated integration and demo readiness. It does not prove he formally led the team or reviewed every PR; use “coordinated” unless the team can independently confirm a leadership title.

## 6. Functionality that should be credited to the team or others

The following distinctions are important in interviews:

- **Devise authentication:** began in the Le Wagon template. Edward configured and used it, but did not create Devise authentication from scratch.
- **Google OAuth:** Bianca introduced it in `8715ecb`; Edward fixed its production/Heroku callback and CSRF configuration.
- **Original patch list/summary UI:** Hortense introduced early patch/summary work in `08066e8`.
- **Stored patch summary service/prompts:** current blame attributes `SummaryService` to Baptiste.
- **Original event summary:** Baptiste introduced it; Edward made it asynchronous and failure-aware.
- **Core patch chatbot backend/data model:** Bianca introduced the chat/message controllers/models and initial live backend; Edward implemented the major streaming front-end and later reliability/UX changes.
- **First friendship/find-friends implementation:** Hortense introduced it; Edward built the later request/accept/decline and modal/search enhancements.
- **First post model/controller:** Hortense introduced it; Edward later added feed ranking/integration and Turbo Stream broadcasting.
- **Overall visual/profile design:** shared across all four contributors, despite Edward's large current share.

## 7. Development complexity and CV relevance

### Full-stack development

Edward's evidence spans migrations/models, SQL/Active Record queries, controllers, services/jobs, server-rendered views, Stimulus JavaScript, SCSS, tests and deployment configuration. This is a genuine end-to-end contribution rather than work isolated to one layer.

### Problem solving and unreliable external data

The ingestion work handles the sort of edge cases common in gaming products: publishers use different markup and APIs; dates can be absent or incorrect; pages can be bot-protected or JavaScript-driven; names/slugs vary; and one failing source should not stop all others. Designing explicit source registries, disabled states, diagnostics and fallbacks demonstrates practical engineering judgement.

### Database design

The application models personalised many-to-many relationships, self-referential friendship state, persisted chat history, typed summaries and JSONB presentation data. Edward has concrete evidence for the initial schema and later additions including publication dates, roles, player modes and AI request/presentation state.

### API and AI integration

The project integrates authenticated IGDB requests, multiple scraped/API sources, two LLM providers, Google OAuth and Cloudinary. The best interview story is not merely “used AI”; it is the reliability layer around AI: structured JSON contracts, validation, persistent state, fallbacks, background execution, streaming UI, contextual prompts and provider failure handling.

### Collaborative Git workflow

The short sprint used many small feature/fix branches and more than 300 PR merges. Edward's 265 PR merges and planning/demo-document commits show active integration and coordination under time pressure. Be ready to explain that commit volume is unusually high because the team used very small branches/PRs and frequent commits.

### Product/UI development

The work translates a real gamer problem into browse/follow/understand/remind/social flows. Edward can discuss prioritising information density, filtering live-service data, responsive poster/card layouts, sticky chat, timeline groupings, follow/reminder feedback and demo-readiness.

### Gaming-industry relevance

The domain is directly relevant: live-service patch cadence, player-impact communication, game catalogues, esports/live events, publisher-source inconsistency and personalised game libraries. The ingestion code also shows the need to respect that game data changes frequently and does not share one standard source format.

## 8. CV-ready section

### 8.1 One-sentence project description

GameBrief is a four-person, two-week Le Wagon Rails project that aggregates live-service game patches and events into a personalised hub with AI-assisted explanations, contextual patch chat, reminders and social profiles.

### 8.2 Concise technology stack

Ruby 3.3 / Rails 8, PostgreSQL, Active Record, ERB, SCSS, Bootstrap, Hotwire (Turbo/Stimulus/Action Cable), Active Job, Devise/Google OAuth, Nokogiri, IGDB/Twitch API, Anthropic, OpenAI via RubyLLM, Cloudinary, Minitest, Heroku and Git/GitHub.

### 8.3 Six possible CV bullet points

- Built a full-stack Rails gaming hub in a four-person, two-week bootcamp sprint, combining game discovery, follows, patch notes, events, reminders, profiles and social feeds.
- Designed a multi-source ingestion pipeline for live game patches and events using source-specific scrapers/importers, central runners, scheduled jobs, deduplication and failure diagnostics.
- Implemented search, multi-criteria filters and personalised ordering across PostgreSQL/Active Record queries and responsive ERB/SCSS interfaces.
- Created an AI-assisted patch-presentation workflow with validated structured JSON, JSONB persistence, background generation, progress UI and a deterministic fallback.
- Built admin tooling for role-protected data imports, per-source status/logs and asynchronous run-all operations, with model/controller/service/job tests.
- Deployed and debugged the application on Heroku/PostgreSQL, resolving OAuth callback, scheduling, custom-domain, streaming and Cloudinary media issues.

### 8.4 Strongest three bullets specifically supported by Edward's contribution

- **Designed and implemented a multi-source Rails ingestion architecture for 29 configured patch sources and 19 event sources, with Nokogiri/API parsers, importers, deduplication, date normalisation, scheduled/background jobs and per-source failure handling.**
- **Built an AI patch-note presentation pipeline using RubyLLM/OpenAI, validating structured JSON into PostgreSQL JSONB, tracking asynchronous generation state and providing deterministic fallback formatting plus automated tests.**
- **Delivered full-stack catalogue, event and admin features—from Active Record filtering/migrations and role-protected controllers to responsive Hotwire/Stimulus UI—and deployed/debugged the Rails/PostgreSQL app on Heroku with Cloudinary and Google OAuth.**

These are stronger and safer than “built the whole app,” “built the chatbot,” or “implemented authentication.”

### 8.5 Technical topics to prepare for an interview

1. Why the scraper/importer/runner separation was chosen and how a new game source is added.
2. How source URL deduplication, replace-versus-upsert behavior and date normalisation work.
3. How Active Record scopes compose game/patch/event filters and how followed-game ordering is implemented.
4. How the AI patch-presentation service validates model output, stores JSONB and falls back when the provider fails.
5. The difference between Anthropic summary flows, GPT patch presentation and the team-built contextual chatbot.
6. SSE token streaming versus Turbo Streams/Action Cable feed broadcasting, including production constraints.
7. The data model for follows, reminders, friendships, posts/likes and per-user patch chats.
8. Devise plus Google OAuth callback handling behind Heroku's HTTPS proxy/custom domain.
9. Background-job choices: why production currently uses `:async`, its durability limitations and what would change with Solid Queue/Sidekiq.
10. Test strategy, what the current failing tests reveal, and how to restore a green build before further development.

### 8.6 Claims Edward should not make

- “I built GameBrief by myself” or wording that hides the four-person team.
- “I wrote all 639 commits/features”; 281 Edward-authored commits are merges, including teammates' branches.
- “I implemented Google OAuth”; Bianca introduced it. Edward can claim production OAuth fixes/configuration.
- “I built authentication from scratch”; the project started from a Le Wagon Devise template.
- “I created the whole AI chatbot”; the backend/models were primarily Bianca's, while Edward built most of the current streaming client and made later enhancements.
- “I created all AI summaries”; Baptiste owns the stored patch summary service and introduced event summaries. Edward owns AI patch presentation and the event-summary background/failure improvements.
- “I created all social features”; Hortense introduced friendships/find-friends and posts; other teammates also contributed profile/social UI.
- “All scrapers are production-ready and fully automated”; some sources are disabled/manual/API-only, external markup is fragile and one removed-source test is stale.
- “The test suite passes” or “production-grade test coverage”; the suite is substantial but currently reports 13 failures and 5 errors.
- “The app uses a durable background queue in production”; the current production adapter is in-process `:async`.
- “I was the team lead” unless Edward and teammates can independently confirm that role; Git supports integration/coordination, not a formal title.
- “It is a native game/game-engine project”; it is a gaming-industry web product, not gameplay, graphics or engine programming.

## 9. Recommended interview framing

A concise, defensible explanation would be:

> “GameBrief was our four-person Le Wagon final project, built in roughly two weeks. It helps casual players keep up with live-service games by aggregating patches and events and adding personalised and AI-assisted views. My main responsibility became the data-ingestion and integration layer: I established the initial domain model and IGDB catalogue, built the scraper/importer runners across many game sources, implemented much of the filtering and admin tooling, created the structured AI patch-presentation workflow, and handled a lot of the Heroku production debugging. Other teammates originally built areas such as Google OAuth, stored summaries, the core chat backend and the first social models; I integrated with and extended those areas.”

That account matches the repository and gives clear openings for deeper technical discussion without overstating sole ownership.

## Appendix A: selected Git evidence

| Area | Selected Edward-authored non-merge commits | Evidence |
|---|---|---|
| Foundation/data model | `51e4cdd`, `0b56c48`, `581e840`, `ad5e7c6` | Initial domain models, migrations, schema, game views and seeds |
| IGDB | `bf37fea` | IGDB client, model/view/seed integration |
| Games discovery | `7213d3a`, `41cd654`, `e8dc1cc`, `fe1cc4f`, `9a12be8`, `a48137c` | Search, filters, schema changes, views and tests |
| Patch ingestion | `0ed6da8`, `5d95e29`, `115edc7`, `9f4ee5a`, `d7bd47e` | Scraper/importer/jobs, shared runner, scheduling, resilient run-all |
| Dates/patch UX | `0ecbe7d`, `9b99ac7`, `7f4d8cd`, `ab87bb1`, `f3e8790` | Publication dates, cross-source fixes, sort/filter/badges |
| AI patch presentation | `beb83f9`, `893a986` | Service, fallback, job, model state, UI and tests |
| Streaming chat contribution | `4928ba6`, `e0d400b`, `87a5458`, `0a9b818` | Streaming Stimulus client, rendering/UX and production fixes |
| Event AI improvements | `adcd354`, `3b62140` | Background generation and provider cooldown/failure handling |
| Admin/asynchronous operations | `4c906cb`, `38ea435`, `8f8c349`, `6885934` | Roles, admin UI/logs, background patch/event run-all workflows |
| Profile/social extensions | `72143ec`, `6dd0bd5`, `75e4dd8`, `392b5da`, `86bbebf` | Public profiles, request flow, realtime feed, bio/moderation |
| Deployment | `3fe2eb5`, `dc749b0`, `e19a675`, `9f4ee5a`, `8677a15`, `0a9b818` | PostgreSQL/Heroku, OAuth/domain, scheduler, Cloudinary, streaming |

## Appendix B: selected evidence of others' original ownership

| Area | Commit/author evidence | Attribution implication |
|---|---|---|
| Early patches/summaries | `08066e8`, Hortense | Team feature; not solely Edward's |
| Google OAuth | `8715ecb`, Bianca | Bianca introduced; Edward fixed deployment configuration |
| Stored patch summary service | current `SummaryService` blame: Baptiste | Do not attribute original summary prompts/service to Edward |
| Event summary service | `d4aea99`, Baptiste | Edward later redesigned background/failure behavior |
| Chat models/controllers | `c073def`, Bianca; `8469ea1`, Bianca | Edward's claim should focus on streaming client and enhancements |
| Initial friendships/find friends | `3d7781a` and related commits, Hortense | Edward later implemented request-state/UX expansion |
| Post model/controller | `ded68a2`, Hortense | Edward later added feed integration/broadcasting |

## Appendix C: quantitative Git notes

- Total commits across available refs: 811.
- Total non-merge commits: 469.
- Edward identity: 639 total commits, 358 non-merge commits.
- PR-numbered merge commits: 304 total; 265 authored by Edward, 15 by Hortense, 15 by Bianca and 9 by Baptiste.
- Human development dates in the repository: 9–19 March 2026.
- Current tests discovered/executed: 281 tests, 1,209 assertions, 13 failures, 5 errors, 0 skips.

These numbers are useful supporting context, but the feature-level commit evidence is more meaningful for a CV than raw commit volume.
