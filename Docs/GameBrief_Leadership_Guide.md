# GameBrief --- Project Leadership Guide

This document is designed for the **project leader** of the GameBrief
project. It contains practical advice for managing a short project with
a team that has around **2 months of coding experience**.

The goal is to keep the team focused, reduce stress, and ensure a
**working demo** by the end of the project.

------------------------------------------------------------------------

# Core Leadership Philosophy

For a short project like this, success is defined as:

• A working application\
• A clear demo of the idea\
• A stable deployed app

Not perfect architecture or perfect code.

Your job as leader is to:

• keep the project focused\
• unblock teammates when they get stuck\
• ensure the team is building the **right things first**

------------------------------------------------------------------------

# The Most Important Rule: Control Scope

The biggest risk in short projects is **trying to build too much**.

Always prioritise the **Minimum Viable Product (MVP)**.

### GameBrief MVP

The demo should ideally show:

1.  Google login
2.  Games list page
3.  Game detail page
4.  Ability to follow games
5.  Patch summary display
6.  Events shown for games
7.  Deployed on Heroku

Anything beyond this is optional.

When new ideas appear, ask:

> "Does this help the demo?"

If not, move it to a **nice-to-have list**.

------------------------------------------------------------------------

# Your Role as Leader

Even if you are coding, your main responsibilities are:

### 1. Keep the team aligned

Make sure everyone understands:

• the current goal\
• what feature they are responsible for\
• what stage the project is in

### 2. Remove blockers

Common blockers for beginner teams:

• Git conflicts\
• Rails errors\
• migrations failing\
• APIs not working

Help the team solve these quickly.

### 3. Protect project stability

Encourage:

• small commits\
• frequent merges\
• testing after merges

------------------------------------------------------------------------

# Tips for Managing Beginner Developers

Because the team has only been coding for a few months:

### Keep architecture simple

Avoid:

• complex service layers\
• advanced patterns\
• unnecessary abstraction

Use straightforward Rails patterns.

### Prefer visible progress

People stay motivated when they see results.

Examples:

• pages loading\
• buttons working\
• UI improving

### Encourage asking questions

Make it normal to ask for help quickly instead of struggling alone.

------------------------------------------------------------------------

# Recommended Team Workflow

A safe workflow for beginner teams:

1.  Create a shared skeleton project
2.  Divide feature ownership
3.  Work in separate branches
4.  Merge frequently
5.  Test after merges

------------------------------------------------------------------------

# Git Workflow Recommendation

Each developer should work in their own branch.

Example:

feature/authentication\
feature/games\
feature/patches\
feature/events

Never develop directly on **main**.

Typical workflow:

1.  Pull latest main
2.  Create or switch to feature branch
3.  Work and commit small changes
4.  Push branch
5.  Open pull request
6.  Merge after review/testing

------------------------------------------------------------------------

# High Risk Files (Merge Conflicts)

Be careful with these files:

config/routes.rb\
db/schema.rb\
db/migrate\
application.html.erb

Coordinate changes with the team.

------------------------------------------------------------------------

# Daily Check-In Structure

Short daily check-ins help avoid hidden problems.

Each person answers:

• What did you complete yesterday?\
• What are you working on today?\
• Are you blocked?

Even a **5-minute check-in** is helpful.

------------------------------------------------------------------------

# First Few Days Suggested Plan

This is not a strict timeline, but a **recommended order** to reduce
confusion.

------------------------------------------------------------------------

## Day 1 --- Project Foundations

Goals:

• create the Rails project\
• setup Git repository\
• install Devise\
• confirm the app runs locally for everyone

Tasks:

• create Rails project\
• push project to GitHub\
• everyone clones repo\
• confirm app runs locally\
• install authentication gems

Outcome:

Everyone can run the project locally.

------------------------------------------------------------------------

## Day 2 --- Authentication + Models

Goals:

• login working\
• main database models created

Tasks:

• setup Devise authentication\
• configure Google OAuth\
• create models:

User\
Game\
Patch\
PatchSummary\
Event\
Favourite\
Reminder

Outcome:

Database structure is ready.

------------------------------------------------------------------------

## Day 3 --- Game Data + Pages

Goals:

• import games\
• build core pages

Tasks:

• integrate IGDB API\
• import some games\
• create GamesController\
• build:

Games index page\
Game show page

Outcome:

Users can browse games.

------------------------------------------------------------------------

## After That

The team can work more independently on:

• patch pages\
• summaries\
• follow system\
• events\
• UI improvements\
• deployment

------------------------------------------------------------------------

# Demo Preparation Advice

Before the final demo:

Make sure the demo flow works smoothly:

1.  Login
2.  View games
3.  Open a game
4.  See patch summary
5.  Follow game
6.  View events

Practice the demo once or twice.

------------------------------------------------------------------------

# Morale and Team Energy

Short projects can get stressful.

Help keep the team positive by:

• celebrating small wins\
• recognising progress\
• keeping communication friendly

A relaxed team builds faster than a stressed one.

------------------------------------------------------------------------

# Final Reminder

The goal is **not perfect code**.

The goal is:

> A working product that clearly demonstrates the idea.

Keep things simple, keep the team moving, and you will succeed.

------------------------------------------------------------------------

End of file
