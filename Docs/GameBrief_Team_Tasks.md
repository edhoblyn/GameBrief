# GameBrief — Team Tasks

> Last updated: 2026-03-12 | Focus: keep 2 active rounds of work with one main task per teammate in each round

---

## How To Use This Task Sheet

- There are 2 rounds of work
- The team has 4 members, so each round contains 4 main tasks
- Completed tasks are moved out of the rounds so the board stays current
- Each task keeps a unique colour/symbol label so it is easy to reference in standups and chat

---

## Recently Completed

These are done and should stay out of the active rounds unless bugs appear.

### Completed Task A - Baptiste

**Brand Pass** 🔵

**Task:** **Change the browser tab icon and add the GameBrief logo on the homepage**

**Done?** ✅

### Completed Task B - Hortense / Bianca / Ed

**Profile Refresh** 🔴

**Task:** **My Profile layout and sidebar updates** — reduce empty space, rebuild the profile layout, and make the sidebar / notification controls fit the new structure

**Done?** ✅

### Completed Task C - Team

**Profile Split** 🟢

**Task:** **Dedicated profile sub-pages** — move My Games, My Patches, and My Events into proper standalone pages

**Done?** ✅

---

## Round 1 — Team Priority Tasks

These should be treated as the first active round.

### Task 1 - Ed

**Fresh Badge** 🩷

**Task:** **"New" badge on patches** — use `published_at` and show a visible badge on recent patches from the last 7 days on patch cards and relevant views

**Why it matters:** The backend support already exists, so this is a fast demo-quality win with low implementation risk.

**Done?** ⬜

### Task 2 - Baptiste

**Event Lens** 🟡

**Task:** **Events page filters** — add game filter plus time filter (`This Week`, `This Month`, `Future`, `All`) on the events index

**Why it matters:** This is one of the clearest missing product features and brings the events flow closer to the patches experience.

**Done?** ⬜

### Task 3 - Hortense

**Mobile Sweep** ⭐️

**Task:** **Mobile responsiveness pass** — check and fix My Profile, patches, events, and games pages on small screens

**Why it matters:** The current layouts are much richer now, so they need a proper phone-size pass before demo use.

**Done?** ⬜

### Task 4 - Bianca

**Real Recs** 🟣

**Task:** **My Profile recommendations pass** — replace the current placeholder recommendation state with a first real recommendation block based on followed games or genres

**Why it matters:** The UI is already there, but it still reads as placeholder content until some real logic is behind it.

**Done?** ⬜

---

## Round 2 — Important Follow-Up Tasks

These are the next 4 active tasks once Round 1 is underway or finished.

### Task 1 - Ed

**Free Queue** 💙

**Task:** **Free-to-play filter** — add a real free-to-play filter on the games index, including any data support needed for the current tracked games

**Why it matters:** It extends the existing games filtering system cleanly and adds a useful browse shortcut.

**Done?** ⬜

### Task 2 - Baptiste

**Safe Clicks** 🟤

**Task:** **Loading / disabled states on Generate Summary buttons** — prevent double submits on patch and event summary actions

**Why it matters:** This closes a known UX gap and reduces accidental duplicate AI requests during demos.

**Done?** ⬜

### Task 3 - Hortense

**Event Polish** 🧡

**Task:** **Events page visual pass** — once filters exist, tighten card layout, filter spacing, and empty states so the events page feels finished

**Why it matters:** The events page is functional, but still lighter on polish than the newer profile and patches views.

**Done?** ⬜

### Task 4 - Bianca

**Notify Hub** 📣

**Task:** **Notification centre placeholder page** — add a simple in-app notifications page tied to patch drops, reminders, and recommendation updates

**Why it matters:** The profile already implies notification settings, so this gives those controls a clearer destination.

**Done?** ⬜

---

## Suggested Backup Tasks

Use these if someone finishes early or gets blocked.

| Backup task | Suggested owner | Why |
| --- | --- | --- |
| **Chat Archive** 🩵 — **Saved AI chats** | **Baptiste** | Good extension of the chat system that already exists |
| **Patch Palette** ❤️ — **Colour-coded update categories on game pages** | **Bianca** | Best fit for user-facing game page presentation |
| **Scrape Gate** 🛠️ — **Admin scrape access check / fix** | **Ed** | Important because the current admin scrape route depends on `current_user.admin?` |
| **Card Glow** 💜 — **Patch/event card refinement pass** | **Hortense** | Best fit for consistency after the main mobile pass |

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
2. Patch freshness badge shipped
3. Summary buttons protected against duplicate submits
4. A proper mobile pass completed on the major user-facing pages
5. At least one Round 2 follow-up task started or completed
