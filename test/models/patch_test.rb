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
end
