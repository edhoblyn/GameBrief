# GameBrief --- Database Schema Reference

## Users

Columns: - email - encrypted_password - provider - uid - username

Relationships: - has_many favourites - has_many games through
favourites - has_many reminders

## Games

Columns: - name - slug - cover_image_url

Relationships: - has_many patches - has_many events - has_many
favourites

## Patches

Columns: - version - title - raw_content - source_url - published_at

Relationships: - belongs_to game - has_many patch_summaries

## PatchSummaries

Columns: - summary_type - content - model

Relationships: - belongs_to patch

## Events

Columns: - title - description - starts_at - ends_at

Relationships: - belongs_to game - has_many reminders

## Reminders

Columns: - remind_at

Relationships: - belongs_to user - belongs_to event
