require "test_helper"

class PatchesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "patches-controller@test.com", password: "123456")
    sign_in @user
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

  test "sorts patches by oldest when requested" do
    game = Game.create!(name: "Patch Oldest Game", slug: "patch-oldest-game")
    Patch.create!(game: game, title: "Older Patch", content: "Notes", published_at: 10.days.ago)
    Patch.create!(game: game, title: "Newer Patch", content: "Notes", published_at: 2.days.ago)
    Patch.create!(game: game, title: "Unknown Date Patch", content: "Notes", source_url: "https://example.com/unknown")

    get patches_url(sort: "oldest")

    assert_response :success
    assert_equal ["Older Patch", "Newer Patch", "Unknown Date Patch"], rendered_patch_titles.first(3)
  end

  private

  def rendered_patch_titles
    Nokogiri::HTML(response.body).css(".card-title").map(&:text).map(&:strip)
  end
end
