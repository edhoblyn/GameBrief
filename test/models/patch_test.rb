require "test_helper"

class PatchTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    ActiveJob::Base.queue_adapter = :test
  end

  test "effective_published_at falls back to created_at" do
    game = Game.create!(name: "Test Game", slug: "test-game")
    patch = Patch.create!(game: game, title: "Patch", content: "Notes")

    assert_equal patch.created_at.to_i, patch.effective_published_at.to_i
  end

  test "with_date_filter returns only patches in the selected range" do
    game = Game.create!(name: "Date Filter Game", slug: "date-filter-game")
    recent_patch = Patch.create!(game: game, title: "Recent", content: "Notes", published_at: 3.days.ago)
    old_patch = Patch.create!(game: game, title: "Old", content: "Notes", published_at: 40.days.ago)

    filtered_patches = Patch.with_date_filter("last_30_days")

    assert_includes filtered_patches, recent_patch
    assert_not_includes filtered_patches, old_patch
  end

  test "display_published_at falls back to a demo date for synthetic scrape timestamps" do
    game = Game.create!(name: "Synthetic Date Game", slug: "synthetic-date-game")
    created_at = Time.zone.parse("2026-03-11 12:00:00")

    patch = Patch.create!(
      game: game,
      title: "Scraped Patch",
      content: "Notes",
      source_url: "https://example.com/patch",
      published_at: created_at,
      created_at: created_at,
      updated_at: created_at
    )

    assert_includes 180.days.ago.to_date..Time.zone.today, patch.display_published_at.to_date
  end

  test "import_attributes clears synthetic scrape timestamps when no better date exists" do
    game = Game.create!(name: "Import Date Game", slug: "import-date-game")
    created_at = Time.zone.parse("2026-03-11 12:00:00")
    patch = Patch.create!(
      game: game,
      title: "Scraped Patch",
      content: "Notes",
      source_url: "https://example.com/patch",
      published_at: created_at,
      created_at: created_at,
      updated_at: created_at
    )

    attrs = Patch.import_attributes(
      {
        title: "Updated title",
        content: "Updated notes",
        published_at: nil
      },
      game: game,
      existing_patch: patch
    )

    assert_nil attrs[:published_at]
  end

  test "import_attributes replaces future scraped date with source url date when available" do
    game = Game.create!(name: "Future Date Game", slug: "future-date-game")

    attrs = Patch.import_attributes(
      {
        title: "Future dated patch",
        content: "Notes",
        source_url: "https://example.com/patchnotes/2025/12/31/future-dated-patch",
        published_at: Time.zone.parse("2026-12-31")
      },
      game: game,
      existing_patch: nil
    )

    assert_equal Time.zone.parse("2025-12-31").to_i, attrs[:published_at].to_i
  end

  test "import_attributes clears future scraped date when no safe fallback exists" do
    game = Game.create!(name: "Unknown Future Date Game", slug: "unknown-future-date-game")

    attrs = Patch.import_attributes(
      {
        title: "Future dated patch",
        content: "Notes",
        source_url: "https://example.com/patch/future-dated-patch",
        published_at: 2.months.from_now
      },
      game: game,
      existing_patch: nil
    )

    assert_nil attrs[:published_at]
  end

  test "display_published_at falls back to a demo date for future scraped dates" do
    game = Game.create!(name: "Future Display Game", slug: "future-display-game")
    patch = Patch.create!(
      game: game,
      title: "Future Patch",
      content: "Notes",
      source_url: "https://example.com/patch/future-patch",
      published_at: 2.months.from_now
    )

    assert_includes 180.days.ago.to_date..Time.zone.today, patch.display_published_at.to_date
  end

  test "display_published_at demo fallback is deterministic" do
    game = Game.create!(name: "Demo Fallback Game", slug: "demo-fallback-game")
    created_at = Time.zone.parse("2026-03-11 12:00:00")
    patch = Patch.create!(
      game: game,
      title: "Undated Patch",
      content: "Notes",
      source_url: "https://example.com/patch/undated",
      published_at: created_at,
      created_at: created_at,
      updated_at: created_at
    )

    assert_equal patch.display_published_at.to_i, patch.display_published_at.to_i
  end

  test "request_ai_presentation! enqueues a background job for content-only patches" do
    game = Game.create!(name: "AI Queue Game", slug: "ai-queue-game")
    patch = Patch.create!(
      game: game,
      title: "Queued Patch",
      content: "Notes"
    )

    patch.update_columns(ai_presentation_requested_at: nil, ai_presentation_generated_at: nil)

    assert_enqueued_with(job: GeneratePatchPresentationJob, args: [patch.id]) do
      assert patch.request_ai_presentation!
    end
  end

  test "ai presentation is ready when structured sections exist and generation is current" do
    game = Game.create!(name: "AI Ready Game", slug: "ai-ready-game")
    patch = Patch.create!(
      game: game,
      title: "Ready Patch",
      content: "Notes",
      source_url: "https://example.com/patch/ready"
    )

    patch.update_columns(
      structured_sections: [{ "title" => "Highlights", "summary" => "Main changes", "content" => "- Buffs" }],
      ai_presentation_generated_at: Time.current
    )

    assert patch.ai_presentation_ready?
    assert_not patch.ai_presentation_pending?
  end

  test "display_structured_sections falls back to locally formatted sections when AI output is missing" do
    game = Game.create!(name: "Fallback Presentation Game", slug: "fallback-presentation-game")
    patch = Patch.create!(
      game: game,
      title: "Fallback Patch",
      content: <<~TEXT
        Weapons
        - Rifle damage reduced

        Ranked
        - Rewards updated
      TEXT
    )

    assert_equal ["Weapons", "Ranked"], patch.display_structured_sections.map { |section| section["title"] }
    assert_nil patch.display_formatted_content
  end

  test "wall_of_text? detects oversized paragraph-heavy patches" do
    game = Game.create!(name: "Wall Of Text Game", slug: "wall-of-text-game")
    patch = Patch.create!(
      game: game,
      title: "Longform Patch",
      content: <<~TEXT
        This is a very long introductory paragraph that keeps going without bullets or headings and is intended to mimic a developer blog style patch note where everything is delivered as prose instead of clearly separated sections for players to scan quickly on the page. It continues with enough detail to cross the long paragraph threshold and make the reading experience feel dense.

        This second paragraph continues the same pattern with additional explanation about maps, heroes, modes, and event scheduling, but still does not offer any structured bullets for the reader. The goal here is to ensure the model treats this as a wall of text rather than a normal short patch note that can wait for the background formatter.

        A final large paragraph closes out the update with more narrative context, rollout notes, and community messaging so the total body length is comfortably above the threshold used for synchronous AI formatting.
      TEXT
    )

    assert patch.wall_of_text?
    assert patch.prefers_synchronous_ai_formatting?
  end

  test "wall_of_text? ignores short structured notes" do
    game = Game.create!(name: "Structured Short Game", slug: "structured-short-game")
    patch = Patch.create!(
      game: game,
      title: "Short Patch",
      content: <<~TEXT
        Weapons
        - Rifle damage reduced

        Ranked
        - Rewards updated
      TEXT
    )

    assert_not patch.wall_of_text?
    assert_not patch.prefers_synchronous_ai_formatting?
  end
end
