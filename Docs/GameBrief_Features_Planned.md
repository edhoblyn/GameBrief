# GameBrief — Features Planned

> Last updated: 2026-03-14

---

## Highest Priority Product Gaps

These are the clearest missing features based on the current Rails app and UI.

- Persisted notification preferences instead of `localStorage`-only toggles on `My Profile`
- Real recommendation logic for the recommendations panel on `My Profile`
- Editable bio and real profile stats instead of the current hard-coded `My Profile` filler values
- Loading / disabled states for the patch summary generation actions

## Strong Next Features

- Patch chat history list so users can reopen older patch conversations instead of only continuing the current per-patch chat
- Notification centre / inbox for reminders, patch drops, and recommendation updates
- Pagination on games, patches, events, and user search results
- Better events browse polish beyond the new filters: layout cleanup, stronger empty states, and tighter mobile spacing
- Reminder confirmation emails or digest emails

## Social / Community Work Still Missing

- Replace mock `For You` / `Communities` feed content with stored app data
- Real community membership or join/leave flows
- Richer public player profiles with persisted activity beyond the current basic counts
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

- Event filtering is now live on `events#index`, including time-range controls and multi-game filtering.
- Users can already find friends, add/remove friendships, and open basic player profile pages.
- `My Profile` still contains presentation-first sections backed by mock data, especially in `For You`, `Communities`, and recommendations.
- Profile editing supports username plus avatar/cover uploads, but the displayed bio and some profile stats are still hard-coded in the view.
- Patch chat data is persisted in `chats` and `messages`, but there is not yet a user-facing history/index for browsing older conversations.
