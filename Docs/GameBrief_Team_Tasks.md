# GameBrief — Team Tasks

> Last updated: 2026-03-12 | Focus: keep the current end-of-day board intact, reflect what already landed in code, and leave completed items visible for tomorrow's team reset

---

## How To Use This Task Sheet

- There are 2 rounds of work
- The team has 4 members, so each round contains 4 main tasks
- Completed tasks are moved to `Docs/GameBrief_Team_Progress.md` so the board stays current
- Each task keeps a unique colour/symbol label so it is easy to reference in standups and chat

---

## Round 1 — Team Priority Tasks

These should be treated as the first active round.

### Task 1 - Baptiste

**Event Lens** 🟡

**Task:** **Events page filters** — add game filter plus time filter (`This Week`, `This Month`, `Future`, `All`) on the events index

**Why it matters:** This is one of the clearest missing product features and brings the events flow closer to the patches experience.

**Done?** ⬜

### Task 2 - Bianca

**Real Recs** 🟣

**Task:** **My Profile recommendations pass** — replace the current placeholder recommendation state with a first real recommendation block based on followed games or genres

**Why it matters:** The UI is already there, but it still reads as placeholder content until some real logic is behind it.

**Done?** ⬜

### Task 3 - Ed

**Scrape Gate** 🛠️

**Task:** **Admin scrape access check / fix** — review the admin scrape route and make sure access works correctly with the current `current_user.admin?` requirement

**Why it matters:** The scrape tooling is high-value for demo freshness, and this path is currently fragile if admin checks are misconfigured.

**Done?** ✅

**Note:** Admin gating, manual scrape actions, scrape logs, and admin role management are now present in the app, so this can be treated as completed and left on the board for end-of-day visibility.

### Task 4 - Hortense

**Event Polish** 🧡

**Task:** **Events page visual pass** — once filters exist, tighten card layout, filter spacing, and empty states so the events page feels finished

**Why it matters:** The events page is functional, but still lighter on polish than the newer profile and patches views.

**Done?** ⬜

---

## Round 2 — Important Follow-Up Tasks

These are the next 4 active tasks once Round 1 is underway or finished.

### Task 1 - Baptiste

**Safe Clicks** 🟤

**Task:** **Loading / disabled states on Generate Summary buttons** — prevent double submits on patch and event summary actions

**Why it matters:** This closes a known UX gap and reduces accidental duplicate AI requests during demos.

**Done?** ⬜

### Task 2 - Bianca

**Notify Hub** 📣

**Task:** **Notification centre placeholder page** — add a simple in-app notifications page tied to patch drops, reminders, and recommendation updates

**Why it matters:** The profile already implies notification settings, so this gives those controls a clearer destination.

**Done?** ⬜

### Task 3 - Ed

**Reminder Copy** 📝

**Task:** **Reminder confirmation and empty-state polish** — tighten reminder success messaging and make the no-reminders state feel more intentional

**Why it matters:** It is a compact UX task that improves the reminders flow without needing new backend work.

**Done?** ⬜

### Task 4 - Hortense

**Card Glow** 💜

**Task:** **Patch/event card refinement pass** — tighten spacing, hover states, and consistency across the patch and event card system after the mobile pass

**Why it matters:** It is a focused polish task that builds directly on the recent responsiveness work and helps the main feeds feel more finished.

**Done?** ⬜

---

## Suggested Backup Tasks

Use these if someone finishes early or gets blocked.

| Backup task | Suggested owner | Why |
| --- | --- | --- |
| **Chat Archive** 🩵 — **Saved AI chats** | **Baptiste** | Good extension of the chat system that already exists |
| **Patch Palette** ❤️ — **Colour-coded update categories on game pages** | **Bianca** | Best fit for user-facing game page presentation |
| **Friends Feed** 🤝 — **Activity snippets from followed players** | **Hortense** | Good follow-on if the social/profile pages need one more lightweight enhancement |
| **Filter Count** 🧭 — **Games/events active filter count or summary text** | **Ed** | Useful small UX improvement once the filtering surfaces are a bit richer |
| **Summary Labels** 🧾 — **Clearer summary type labels and helper text** | **Baptiste** | Useful polish for the AI summary experience already in place |

---

## Suggested Split By Strength

Use this only as guidance if the team wants a quick starting point.

| Team strength area | Best fit based on progress so far |
| --- | --- |
| Scrapers, importers, game data, infra | **Ed** |
| Styling, responsive checks, page polish | **Hortense** |
| Patches, summaries, chatbot, event logic | **Baptiste** |
| Profile page, reminders, social/discovery UI | **Bianca** |

---

## End-of-Day Goal

By the end of the next cycle, the team should aim to have:

1. Events filters shipped
2. Recommendation placeholder content replaced with a first real block
3. Summary buttons protected against duplicate submits
4. Notification / reminder UX moved beyond placeholder controls and basic flashes
5. At least one events/reminders polish task started after the current round
