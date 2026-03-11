require "test_helper"

class PatchTest < ActiveSupport::TestCase
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

  test "display_published_at hides synthetic scrape timestamps" do
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

    assert_nil patch.display_published_at
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
end
