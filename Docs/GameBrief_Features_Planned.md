# GameBrief — Features Planned

> Last updated: 2026-03-13

---

## Highest Priority Product Gaps

These are the clearest missing features based on the current Rails app and UI.

- Events index filters by game and time range (`This Week`, `This Month`, `Future`, `All`)
- Persisted notification preferences instead of `localStorage`-only toggles on `My Profile`
- Real recommendation logic for the recommendations panel on `My Profile`
- Loading / disabled states on patch and event AI summary actions

## Strong Next Features

- Patch chat history list so users can reopen older patch conversations instead of only continuing the current per-patch chat
- Notification centre / inbox for reminders, patch drops, and recommendation updates
- Pagination on games, patches, events, and user search results
- Editable bio and real profile stats instead of the current hard-coded `My Profile` filler values
- Reminder confirmation emails or digest emails
- Better empty states and filter layout polish on events once filtering exists

## Social / Community Work Still Missing

- Follow other users
- Public player profiles with real social relationships and persisted activity
- Replace mock `For You` / `Communities` feed content with stored app data
- Real community membership or join/leave flows
- Patch comments or reactions
- Shareable patch links / share UI

## Product / UX Enhancements

- Patch comparison view between latest and previous updates
- Patch difficulty / impact meter for casual players
- Trending activity feed for followed games
- Platform tags on game cards and game detail pages
- Live Twitch / creator module on game pages
- Player onboarding quiz for genres and platform preferences

## Longer-Term Ideas

- Unreleased games section sourced from IGDB
- Follow upcoming games and notify users at launch
- Achievements / streaks / badges
- Developer-facing analytics or retention dashboard

## Notes

- `My Profile` already has recommendation, community, and feed-shaped UI, but those sections are still mostly presentation-first and backed by mock data in the template.
- `Find Friends` exists for general users, but the `Players` index is currently admin-only via `UsersController#index`.
- Profile editing supports username, avatar, and cover uploads, but the displayed bio and several profile stats are still hard-coded in the view.
- Patch chat data is persisted in `chats` and `messages`, but there is not yet a user-facing index for browsing past conversations.
