# GameBrief — Features Planned

> Last updated: 2026-03-12

---

## Highest Priority Gaps

These still look like the clearest missing demo features based on the current codebase.

- Events index filters by game and time range (`This Week`, `This Month`, `Future`, `All`)
- Visible `NEW` badge for recent patches using `published_at`
- Loading / disabled states on patch and event summary buttons
- Mobile responsiveness pass across My Profile, games, patches, and events pages

## Strong Next Features

- Saved AI chats so users can revisit older patch conversations
- Real recommendation engine behind the current My Profile recommendation area
- Notification centre or inbox for reminders, patch drops, and recommendation updates
- Reminder digest emails or event reminder confirmation emails
- Free-to-play filter on the games index
- Pagination on games, patches, and events

## Product / UX Enhancements

- Trending or activity feed for followed games
- Patch comparison view between the latest and previous patch
- Patch difficulty / impact meter for casual players
- Live Twitch streamer module on game pages
- Colour-coded patch/update categories on game pages
- Platform tags on game cards and game pages
- Player onboarding quiz for genres and platform preferences

## Social / Community Ideas

- Follow other users
- Public player profiles with real social data
- Patch comments or reactions
- Shareable patch links / share UI
- Real community pages instead of the current My Profile mock community cards

## Longer-Term Ideas

- Unreleased games section sourced from IGDB
- Follow upcoming games and notify users at launch
- Achievements / streaks / badges
- Developer-facing analytics or retention dashboard

## Notes

- The My Profile page already contains recommendation, community, and social-feed style UI, but those areas are currently presentation-first and not backed by real persisted social data.
- `published_at` now exists on patches, so the patch freshness badge should be a relatively small follow-up rather than a schema project.
