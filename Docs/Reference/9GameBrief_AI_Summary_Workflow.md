# GameBrief — AI Summary Workflow

> Last updated: 2026-03-17

## Purpose

Transform long patch notes and event descriptions into short, useful summaries for casual gamers.

## Patch Summaries

### Summary Types

Three summary types are stored per patch in `patch_summaries`:

| summary_type | Label | Purpose |
| --- | --- | --- |
| `quick_summary` | Quick Summary | Short overview of what changed |
| `casual_impact` | Casual Impact | What this means for a casual player |
| `should_i_log_in` | Should I Log In? | Direct answer: is this patch worth logging in for? |

### How It Works

1. User opens a patch page
2. User clicks "Generate" for a summary type
3. `PatchesController#generate_summary` is called
4. `SummaryService` sends the patch `content` plus a type-specific prompt to **Claude Opus 4.6** via the `anthropic` gem
5. The response is saved as a `PatchSummary` record (or replaces the existing one for that type)
6. The summary is rendered on the patch page

### SummaryService

Located at `app/services/summary_service.rb`.

- Uses Claude Opus 4.6
- Prompts and labels for all three types are centralised in this service
- Regenerating a type replaces the existing summary record

---

## Patch Presentation (Structured Notes)

Separate from summaries, patch notes can also be reformatted into structured AI sections for easier reading.

### Patch Presentation Flow

1. Admin or scraper imports raw patch text into `patches.content`
2. User visits the patch page and requests structured presentation
3. `PatchPresentationService` sends the raw content to **GPT-4o** via `ruby_llm`
4. The structured output is saved to `patches.structured_sections` (jsonb) and `patches.formatted_content`
5. While generation is in progress, a Turbo frame polls `patches#notes` to show a pending state
6. Once complete, the structured accordion sections replace the raw text

If the AI call fails, `PatchPresentationFallbackService` handles formatting without AI.

Timestamps `ai_presentation_requested_at` and `ai_presentation_generated_at` track generation state.

---

## Patch Chatbot

Users can ask questions about a specific patch via an in-page AI chat.

### Chatbot Flow

1. One `Chat` record exists per user per patch (created on first use)
2. User sends a message; it is saved as a `Message` with `role: "user"`
3. `ChatsController#stream` opens an SSE connection
4. The full conversation history (all prior messages) is sent to **GPT-4o** via `ruby_llm` with patch content injected as context
5. The streamed response is saved as a `Message` with `role: "assistant"` and rendered via Turbo Stream
6. Users are limited to 5 user messages per chat
7. Chat title is auto-generated from the first message

---

## Event Summaries

### Event Summary Flow

1. An event is created or imported into the `events` table
2. `EventSummaryService` sends the event title and description to **Claude Opus 4.6**
3. A one-sentence summary is saved to `events.summary`
4. `events.summary_requested_at` is set and used as a provider cooldown (30-minute guard on API failures)

---

## AI Provider Summary

| Feature | Model | Gem | Field |
| --- | --- | --- | --- |
| Patch summaries (3 types) | Claude Opus 4.6 | `anthropic` | `patch_summaries.summary` |
| Patch presentation | GPT-4o | `ruby_llm` | `patches.structured_sections` |
| Patch chatbot | GPT-4o | `ruby_llm` | `messages.content` |
| Event summaries | Claude Opus 4.6 | `anthropic` | `events.summary` |

---

## Environment Variables Required

```bash
ANTHROPIC_API_KEY   # for Claude (patch summaries, event summaries)
OPENAI_API_KEY      # for GPT-4o (patch presentation, chatbot)
```
