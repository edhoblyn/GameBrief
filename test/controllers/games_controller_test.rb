require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "games-controller@test.com", password: "123456")
    sign_in @user
  end

  test "should get index" do
    get games_url
    assert_response :success
  end

  test "should get show" do
    game = Game.create!(name: "Test Game", slug: "test-game")

    get game_url(game)
    assert_response :success
  end

  test "shows admin panel link in dashboard menu for admins" do
    @user.update!(role: "admin")

    get games_url

    assert_response :success
    assert_includes @response.body, "Admin Panel"
    assert_includes @response.body, admin_dashboard_path
  end

  test "does not show admin panel link in dashboard menu for non-admin users" do
    get games_url

    assert_response :success
    assert_not_includes @response.body, admin_dashboard_path
  end

  test "shows admin scrape button for supported games" do
    @user.update!(role: "admin")
    game = Game.create!(name: "Apex Legends", slug: "apex-legends")

    get game_url(game)

    assert_response :success
    assert_select "form[action='#{admin_patch_scrapes_path}']"
    assert_includes @response.body, "Run Patch Scrape"
  end

  test "shows api badge instead of scrape button for blocked sources" do
    @user.update!(role: "admin")
    game = Game.create!(name: "Fortnite", slug: "fortnite")

    get game_url(game)

    assert_response :success
    assert_select "form[action='#{admin_patch_scrapes_path}']", count: 0
    assert_includes @response.body, "API"
  end

  test "does not show admin scrape button for non-admin users" do
    game = Game.create!(name: "Apex Legends", slug: "apex-legends")

    get game_url(game)

    assert_response :success
    assert_select "form[action='#{admin_patch_scrapes_path}']", count: 0
  end

  test "filters games by free-to-play flag" do
    free_game = Game.create!(name: "Fortnite", slug: "fortnite", free_to_play: true)
    paid_game = Game.create!(name: "Minecraft", slug: "minecraft", free_to_play: false)

    get games_url, params: { free_to_play: "true" }

    assert_response :success
    assert_includes @response.body, free_game.name
    assert_not_includes @response.body, paid_game.name
  end

  test "combines genre and free-to-play filters" do
    matching_game = Game.create!(name: "Apex Legends", slug: "apex-legends", free_to_play: true)
    shooter_paid_game = Game.create!(name: "Helldivers 2", slug: "helldivers-2", free_to_play: false)
    strategy_free_game = Game.create!(name: "Clash Royale", slug: "clash-royale", free_to_play: true)

    Game.connection.execute("UPDATE games SET genre = '{\"Shooter\"}' WHERE id = #{matching_game.id}")
    Game.connection.execute("UPDATE games SET genre = '{\"Shooter\"}' WHERE id = #{shooter_paid_game.id}")
    Game.connection.execute("UPDATE games SET genre = '{\"Strategy\"}' WHERE id = #{strategy_free_game.id}")

    get games_url, params: { genre: "Shooter", free_to_play: "true" }

    assert_response :success
    assert_includes @response.body, matching_game.name
    assert_not_includes @response.body, "Helldivers 2"
    assert_not_includes @response.body, "Clash Royale"
  end

  test "active filters link back to the same page with that filter removed" do
    get games_url, params: { genre: "Shooter", free_to_play: "true", sort: "name", query: "apex" }

    assert_response :success
    assert_select "a[href='#{games_path(query: "apex", sort: "name", free_to_play: "true")}']", text: "Shooter"
    assert_select "a[href='#{games_path(genre: "Shooter", query: "apex", sort: "name")}']", text: "Free-to-play"
    assert_select "a[href='#{games_path(genre: "Shooter", query: "apex", free_to_play: "true")}']", text: "A–Z"
  end

  test "shows follow button on game cards for unfollowed games" do
    game = Game.create!(name: "Fortnite", slug: "fortnite")

    get games_url

    assert_response :success
    assert_includes @response.body, "See details"
    assert_select "form[action='#{favourites_path}'] input[name='game_id'][value='#{game.id}']", count: 1
    assert_select "button[aria-label='Follow #{game.name}'] .fa-star-o", count: 1
  end

  test "shows active follow button on game cards for followed games" do
    game = Game.create!(name: "Apex Legends", slug: "apex-legends")
    favourite = @user.favourites.create!(game: game)

    get games_url

    assert_response :success
    assert_includes @response.body, "View updates"
    assert_select "form[action='#{favourite_path(favourite)}'] input[name='_method'][value='delete']", count: 1
    assert_select "button[aria-label='Unfollow #{game.name}'].game-card__follow-btn--active .fa-star", count: 1
  end
end
