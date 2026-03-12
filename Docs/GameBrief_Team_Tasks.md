# GameBrief — Team Tasks

> Last updated: 2026-03-12

---

## Completed In Current Pass

These items are reflected in the current codebase and should no longer be treated as open.

| Task | Status | Notes |
| --- | --- | --- |
| Brand pass | ✅ Done | Favicon links added in the layout, homepage logo added, featured gamers carousel added |
| My Profile layout pass | ✅ Done | Profile page rebuilt into a fuller social-style layout with populated side panels |
| My Profile sidebar updates | ✅ Done | Notification controls and sidebar navigation now exist in the revised profile layout |
| Dedicated profile sub-pages | ✅ Done | `My Games`, `My Patches`, and `My Events` now have their own pages |

## Current Priority Tasks

These are the clearest remaining tasks based on what is still missing in the app.

| Priority | Task | Suggested owner | Why it matters | Status |
| --- | --- | --- | --- | --- |
| 1 | Events page filters (`game`, `This Week`, `This Month`, `Future`, `All`) | Baptiste or Ed | Still one of the biggest obvious feature gaps on the events flow | ⬜ |
| 2 | Patch `NEW` badge using `published_at` | Ed | Backend support exists already, so this should be a quick high-visibility win | ⬜ |
| 3 | Loading / disabled states on patch and event summary buttons | Baptiste | Prevents duplicate requests and makes AI actions feel more finished | ⬜ |
| 4 | Mobile responsiveness sweep | Hortense | The profile and detail pages still need a proper small-screen pass before demo use | ⬜ |

## Secondary Tasks

Use these once the priority items above are underway.

| Task | Suggested owner | Why |
| --- | --- | --- |
| Free-to-play filter on games index | Ed | Fits the existing games filtering/query work |
| Saved AI chats | Baptiste | Extends the chat system that already exists |
| Recommendation engine behind My Profile callouts | Bianca | The UI is present but the data is still placeholder-level |
| Events page visual polish after filters land | Hortense | Best handled after the page structure is final |

## Watchouts

- The My Profile page now contains social-feed and community UI, but most of that content is mock data rather than real app data.
- `admin/patch_scrapes#create` exists, but admin gating depends on `current_user.admin?`; confirm the user model supports that before relying on it for demo/admin workflows.
- The homepage hero/button styling request looks partially addressed in code, but the original task wording was vague enough that it should be visually checked rather than blindly marked as a separate completed item.

## End-of-Day Goal

1. Ship events filters.
2. Add the patch freshness badge.
3. Remove duplicate-submit risk from AI summary buttons.
4. Close the main mobile layout issues on profile, games, patches, and events.
