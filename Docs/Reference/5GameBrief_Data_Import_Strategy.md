# GameBrief — Data Import Strategy

## Purpose
Define how GameBrief obtains and stores external data such as games, patches, and live events.

## Data Sources

### Game Data
Source: IGDB API

Imported fields:
- name
- slug
- cover_image_url
- genres
- platforms
- release date

Games are periodically synced using a rake task or background job.

### Patch Notes

Possible sources:
- Official developer websites
- RSS feeds
- Manual admin input
- Scraping tools (future)

Initial MVP approach:
Admin manually adds patch notes using an admin interface.

Stored fields:
- version
- title
- raw_content
- source_url
- published_at

### Events

Sources:
- Official game news pages
- Community event calendars
- Developer announcements

MVP approach:
Manual admin entry.

Fields:
- title
- description
- starts_at
- ends_at

## Import Flow

External Source → Import Script → Rails Models → Database

## Heroku Notes

Because the app is deploying to **Heroku**:
- store API credentials in Heroku Config Vars
- test imports in production
- check logs if imports fail

## Future Improvements

- Automated RSS ingestion
- Scheduled patch crawlers
- API integrations with developer endpoints
