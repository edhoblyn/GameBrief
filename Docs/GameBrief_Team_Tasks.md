# GameBrief — Team Tasks

> Last updated: 2026-03-13 | Focus: flexible task queue ordered by priority, not by person

---

## How To Use This Task Sheet

- Use `Now` for the most important active work currently assigned
- Use `Next Up` for work that should be pulled as soon as someone frees up
- Use `Backlog / Backup` for lower-pressure polish or stretch work
- Completed tasks should move to `Docs/GameBrief_Team_Progress.md`
- Keep statuses tied to what is actually in the code, not what was intended
- Do not assign tasks to specific people here; the board should stay flexible for a four-person team with different pacing and interests

---

## Now — Active Priority Tasks

### Task 1

**Event Filters** 🟣

**Task:** Add events index filters for game and time range (`This Week`, `This Month`, `Future`, `All`) and reflect the active filter state in the UI

**Status:** Not started

**Why it matters:** The events page exists, but it is still missing the main browse controls users need to narrow upcoming events quickly.

### Task 2

**Notification Prefs** 🟠

**Task:** Replace `My Profile` notification toggles backed by `localStorage` with persisted user preferences in the database and wire the page to them

**Status:** Not started

**Why it matters:** The notification controls currently look real but do not save to the account, which makes the feature misleading.

### Task 3

**Real Recommendations** 🟢

**Task:** Replace the placeholder recommendations panel on `My Profile` with a first real recommendation block derived from followed games, genres, or free-to-play preferences

**Status:** Not started

**Why it matters:** Recommendations are one of the clearest product promises in the current UI, but the panel is still placeholder-first.

### Task 4

**AI Action States** 🔵

**Task:** Add loading, disabled, and success/error feedback states to patch summary and event summary actions

**Status:** Not started

**Why it matters:** The AI actions work, but the current UI gives weak feedback while a request is in flight.

---

## Next Up — Ready Queue

### Queue Item 1

**Saved Chats** 🩵

**Task:** Surface persisted patch chats in the UI so users can reopen previous conversations instead of only continuing the current patch thread

**Status:** Ready next

**Why it matters:** The data model already stores chats/messages, so the missing work is mostly product surface rather than backend invention.

### Queue Item 2

**Profile Data Pass** 🩷

**Task:** Add editable bio and replace hard-coded `My Profile` stats with real stored values where possible

**Status:** Ready next

**Why it matters:** The account editor exists, but parts of the profile header are still static filler text.

### Queue Item 3

**Events Polish** ⭐️

**Task:** Improve events empty states, filter layout, and mobile spacing after event filtering lands

**Status:** Ready next

**Why it matters:** The events feature will still feel unfinished if the browse surface is not cleaned up after the filter work.

### Queue Item 4

**Pagination Pass** 💙

**Task:** Add pagination to the biggest browse surfaces (`games`, `patches`, `events`, and possibly `find-friends`)

**Status:** Ready next

**Why it matters:** Current index pages work for demo data, but they will not scale cleanly once imports grow.

---

## Backlog / Backup Tasks

| Backup task | Status | Why |
| --- | --- | --- |
| Replace mock `For You` / `Communities` data with persisted social/community data | Backlog | This is important product work, but it is larger than the current polish gaps |
| Add notification centre / inbox for reminders, patch drops, and recommendation updates | Backlog | This becomes more useful once notification preferences are persisted |
| Add patch comparison and share actions on patch pages | Backlog | Good demo value, but not as important as finishing the core browse/recommendation flows |

---

## End-of-Day Goal

By the next planning pass, the board should aim to:

1. Ship event filtering
2. Make notification toggles real and persisted
3. Replace at least one recommendation placeholder with live app data
4. Improve AI action feedback so summary generation feels reliable
