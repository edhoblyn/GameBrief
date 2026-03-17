# GameBrief — Teacher Feedback Checklist

> Last updated: 2026-03-18

---

## Homepage

- [x] Remove the spacer on the homepage only
- [x] Move trending games higher so it becomes visible sooner on scroll
- [x] Sort or fix the homepage carousel swiper
- [x] Move creation flashes/notices lower so they sit beneath the settings icon
- [x] Remove the duplicate homepage logout button because logout is already available in the shared settings menu

## Games Index

- [x] Make the favourite star `position: absolute` in the bottom-right corner of the game card
- [x] Make the search bar bigger
- [x] Reduce the space between the navbar and the search bar
- [x] Fix the `Most favourited` button bug showing params in the game count
- [x] Add a `Sort by` label to the left of the `A-Z` / `Most favourited` buttons

## Game Show Page

- [ ] Investigate the Marvel Rivals patch bug
- [ ] Keep the spacer on the Game Show page

## Events Index

- [x] Remove the `Browse games` button
- [x] Remove the `My events` button
- [x] Update the hero card copy so it clearly explains this is the general events index page

## Event Show Page

- [x] Remove the event snapshot section
- [x] Remove the latest patch section
- [x] Move the background image into the div where the event snapshot currently is
- [x] Change the reminder styling from red background to red border with red text
- [x] Only show `Add to Google Calendar` after `Set Reminder` has been pressed
- [x] Remove the `This week` / `Happening today` flare from the `What is happening` card
- [x] Remove the blurb under the `h1` if it duplicates the event synopsis
- [x] Update the hover state of `Add to Google Calendar`
- [x] Use blue as the secondary colour for the `Add to Calendar` button
- [x] Update countdown text so finished events show `Event over`

## Profile Page

- [ ] Remove post count
- [ ] Make `Friends` link to the full friends list
- [ ] Make `Find friends` open a modal instead of a full-page view
- [ ] Change the `Find friends` button to the secondary colour
- [ ] Keep the `Find friends` button sticky near the Friendhub subheading
- [ ] Make the post form full width in the left-hand column under posts
- [ ] Remove modal behaviour from the post form
- [ ] Add a clearer placeholder for the post form mentioning upcoming events and latest patches
- [ ] Remove the hard-coded event and show the latest real event instead
- [ ] Improve contrast between user info and content with clearer font weights/background colours
- [ ] Order posts by `created_at DESC` so newest posts appear closest to the form
- [ ] Add blue styling in the profile hero/banner area to create cohesion with `My Patches` and `My Events`

## Edit Profile

- [ ] Change `Back to dashboard` to `Back to profile`

## Posts

- [ ] Implement the like functionality

## My Patches

- [ ] Rename `My patches` to `My patch updates`
- [ ] Add a `Back to my profile` button
- [ ] Add images to patch cards
- [ ] Add an `Organise by game` button that displays an accordion of game patches
- [ ] Default landing view should show all patches
- [ ] Add a grey bordered div style to match the profile page

## My Events

- [x] Rename `My events` to `Event reminders`
- [x] Match the UX closely to `My Patches`
- [x] Add a similar search bar to `My Patches`
- [x] Add a similar `Organise by game` button
- [x] Remove the `Browse events` button
- [x] Remove the saved reminders div
- [x] Add a grey bordered div style to match the profile page

## Spacer

- [ ] Make the spacer bigger
- [ ] Remove the spacer across the app
- [ ] Keep the spacer only on the Game Show page and Patch Show page

## Cross-App Consistency

- [ ] Make hero/banner areas consistent across events and games pages
- [ ] Make hero/banner areas consistent across profile, `My Events`, and `My Patches`
- [ ] Make back buttons consistent across the app
- [ ] Keep all back buttons on the left-hand side
- [ ] Use the same back button styling everywhere
- [ ] Make back buttons slightly greyed out so they do not compete with primary CTAs
- [ ] Make tags consistent across the app
- [ ] Use the secondary colour for tags so buttons and cards are easier to distinguish

## Accessibility And QA

- [ ] Run a Lighthouse accessibility check
- [ ] Review font colours and contrast based on Lighthouse feedback
