require "test_helper"

class PatchesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  setup do
    @user = User.create!(email: "patches-controller@test.com", password: "123456")
    sign_in @user
    ActiveJob::Base.queue_adapter = :test
  end

  test "should get index" do
    get patches_url
    assert_response :success
  end

  test "sorts patches by newest when requested" do
    game = Game.create!(name: "Patch Newest Game", slug: "patch-newest-game")
    Patch.create!(game: game, title: "Older Patch", content: "Notes", published_at: 10.days.ago)
    Patch.create!(game: game, title: "Newer Patch", content: "Notes", published_at: 2.days.ago)
    Patch.create!(game: game, title: "Unknown Date Patch", content: "Notes", source_url: "https://example.com/unknown")

    get patches_url(sort: "newest")

    assert_response :success
    assert_equal ["Newer Patch", "Older Patch", "Unknown Date Patch"], rendered_patch_titles.first(3)
  end

  test "filters patches by game when requested" do
    included_game = Game.create!(name: "Included Game", slug: "included-game")
    excluded_game = Game.create!(name: "Excluded Game", slug: "excluded-game")
    Patch.create!(game: included_game, title: "Included Patch", content: "Notes", published_at: 2.days.ago)
    Patch.create!(game: excluded_game, title: "Excluded Patch", content: "Notes", published_at: 1.day.ago)

    get patches_url(game: included_game.id)

    assert_response :success
    assert_equal ["Included Patch"], rendered_patch_titles
  end

  test "sorts patches by oldest when requested" do
    game = Game.create!(name: "Patch Oldest Game", slug: "patch-oldest-game")
    Patch.create!(game: game, title: "Older Patch", content: "Notes", published_at: 10.days.ago)
    Patch.create!(game: game, title: "Newer Patch", content: "Notes", published_at: 2.days.ago)
    Patch.create!(game: game, title: "Unknown Date Patch", content: "Notes", source_url: "https://example.com/unknown")

    get patches_url(sort: "oldest")

    assert_response :success
    assert_equal ["Older Patch", "Newer Patch", "Unknown Date Patch"], rendered_patch_titles.first(3)
  end

  test "shows structured AI sections when available" do
    game = Game.create!(name: "Structured Game", slug: "structured-game")
    patch = Patch.create!(
      game: game,
      title: "Structured Patch",
      content: "Original notes",
      source_url: "https://example.com/patch/structured"
    )
    patch.update_columns(
      formatted_content: "A cleaner overview.",
      structured_sections: [
        { "title" => "Weapons", "summary" => "Balance changes", "content" => "- SMG recoil reduced" }
      ],
      ai_presentation_generated_at: Time.current
    )

    get patch_url(patch)

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_includes response.body, "A cleaner overview."
    assert_includes response.body, "Weapons"
    assert_includes response.body, "Ask about this patch"
  end

  test "shows pending AI message while structured layout is being generated" do
    game = Game.create!(name: "Pending Structured Game", slug: "pending-structured-game")
    patch = Patch.create!(
      game: game,
      title: "Pending Patch",
      content: "Original notes",
      source_url: "https://example.com/patch/pending"
    )

    patch.update_columns(ai_presentation_requested_at: Time.current, ai_presentation_generated_at: nil)

    get patch_url(patch)

    assert_response :success
    assert_includes response.body, "AI is reorganising these scraped patch notes into collapsible sections."
    assert_includes response.body, "15%"
    assert_includes response.body, 'data-controller="patch-presentation"'
    assert_includes response.body, 'data-patch-presentation-target="progress"'
    assert_includes response.body, notes_patch_path(patch)
  end

  test "notes endpoint renders formatted patch notes fragment" do
    game = Game.create!(name: "Notes Endpoint Game", slug: "notes-endpoint-game")
    patch = Patch.create!(
      game: game,
      title: "Notes Endpoint Patch",
      content: "Original notes",
      source_url: "https://example.com/patch/notes-endpoint"
    )
    patch.update_columns(
      formatted_content: "AI overview.",
      structured_sections: [
        { "title" => "Gameplay", "summary" => "Main changes", "content" => "- Movement adjusted" }
      ],
      ai_presentation_generated_at: Time.current
    )

    get notes_patch_url(patch)

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_includes response.body, "AI overview."
    assert_includes response.body, "Gameplay"
  end

  private

  def rendered_patch_titles
    Nokogiri::HTML(response.body).css(".card-title").map(&:text).map(&:strip)
  end
end
