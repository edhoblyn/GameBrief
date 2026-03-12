# GameBrief — Features Planned

> Last updated: 2026-03-12

---

## Highest Priority Gaps

These still look like the clearest missing demo features based on the current codebase.

- Events index filters by game and time range (`This Week`, `This Month`, `Future`, `All`)
- Admin scrape access check/fix against the current `current_user.admin?` gate
- Loading / disabled states on patch and event summary buttons
- Real recommendation logic behind the My Profile recommendation area

## Strong Next Features

- Saved AI chats so users can revisit older patch conversations
- Notification centre or inbox for reminders, patch drops, and recommendation updates
- Reminder digest emails or event reminder confirmation emails
- Pagination on games, patches, and events
- Events page empty-state and filter-layout polish once filtering exists
- Reminder confirmation and no-reminders empty-state polish

## Product / UX Enhancements

- Trending or activity feed for followed games
- Patch comparison view between the latest and previous patch
- Patch difficulty / impact meter for casual players
- Live Twitch streamer module on game pages
- Colour-coded patch/update categories on game pages
- Platform tags on game cards and game pages
- Player onboarding quiz for genres and platform preferences
- Richer profile editing fields such as bio and optional profile stats customization

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

- The My Profile page already contains recommendation, community, and social-feed style UI, but recommendation/community areas are still presentation-first and not backed by real persisted social data.
- Profile editing is now usable for names and images, so the next profile-related work should focus on real recommendation/social data rather than more shell UI.
