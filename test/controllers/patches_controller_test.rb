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
    assert_includes response.body, 'data-controller="chat-stream"'
    assert_includes response.body, "submit-&gt;chat-stream#submit"
    assert_includes response.body, "Questions"
    assert_includes response.body, "0/5"
  end

  test "shows structured fallback sections while ai layout is still generating" do
    game = Game.create!(name: "Pending Structured Game", slug: "pending-structured-game")
    patch = Patch.create!(
      game: game,
      title: "Pending Patch",
      content: <<~TEXT,
        Weapons
        - SMG recoil reduced

        Modes
        - Ranked rewards updated
      TEXT
      source_url: "https://example.com/patch/pending"
    )

    patch.update_columns(ai_presentation_requested_at: Time.current, ai_presentation_generated_at: nil)

    get patch_url(patch)

    assert_response :success
    assert_includes response.body, "Weapons"
    assert_includes response.body, "Modes"
    assert_includes response.body, "SMG recoil reduced"
    assert_not_includes response.body, "AI is reorganising these patch notes into collapsible sections."
  end

  test "shows structured fallback sections for content-only patches" do
    game = Game.create!(name: "Fallback Structured Game", slug: "fallback-structured-game")
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

    get patch_url(patch)

    assert_response :success
    assert_includes response.body, "Weapons"
    assert_includes response.body, "Ranked"
    assert_includes response.body, "Rifle damage reduced"
    assert_not_includes response.body, "AI is reorganising these patch notes into collapsible sections."
  end

  test "formats wall-of-text patches through ai before rendering" do
    game = Game.create!(name: "Wall Of Text Controller Game", slug: "wall-of-text-controller-game")
    patch = Patch.create!(
      game: game,
      title: "Longform Patch",
      content: <<~TEXT,
        This is a very long introductory paragraph that keeps going without bullets or headings and is intended to mimic a developer blog style patch note where everything is delivered as prose instead of clearly separated sections for players to scan quickly on the page. It continues with enough detail to cross the long paragraph threshold and make the reading experience feel dense.

        This second paragraph continues the same pattern with additional explanation about maps, heroes, modes, and event scheduling, but still does not offer any structured bullets for the reader. The goal here is to ensure the model treats this as a wall of text rather than a normal short patch note that can wait for the background formatter.

        A final large paragraph closes out the update with more narrative context, rollout notes, and community messaging so the total body length is comfortably above the threshold used for synchronous AI formatting.
      TEXT
      source_url: "https://example.com/patch/wall-of-text"
    )

    original_new = PatchPresentationService.method(:new)
    PatchPresentationService.define_singleton_method(:new) do |service_patch|
      Object.new.tap do |service|
        service.define_singleton_method(:call) do
          service_patch.update_columns(
            formatted_content: "AI overview for the longform update.",
            structured_sections: [
              { "title" => "Highlights", "summary" => "Big changes", "content" => "- Scarif update details" }
            ],
            ai_presentation_generated_at: Time.current,
            ai_presentation_error: nil
          )
        end
      end
    end

    get patch_url(patch)

    assert_response :success
    assert_includes response.body, "AI overview for the longform update."
    assert_includes response.body, "Highlights"
    assert_includes response.body, "Scarif update details"
  ensure
    PatchPresentationService.define_singleton_method(:new, original_new)
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
