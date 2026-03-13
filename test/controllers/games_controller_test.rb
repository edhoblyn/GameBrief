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

  test "orders game patches newest first on show page" do
    game = Game.create!(name: "Patch Order Test", slug: "patch-order-test")
    older_patch = game.patches.create!(
      title: "Older Update",
      content: "Older content",
      published_at: 10.days.ago
    )
    newer_patch = game.patches.create!(
      title: "Newer Update",
      content: "Newer content",
      published_at: 2.days.ago
    )

    get game_url(game)

    assert_response :success
    assert_operator @response.body.index(newer_patch.title), :<, @response.body.index(older_patch.title)
  end

  test "filters game patches by selected date range on show page" do
    game = Game.create!(name: "Patch Filter Test", slug: "patch-filter-test")
    recent_patch = game.patches.create!(
      title: "Recent Update",
      content: "Recent content",
      published_at: 5.days.ago
    )
    older_patch = game.patches.create!(
      title: "Older Update",
      content: "Older content",
      published_at: 45.days.ago
    )

    get game_url(game), params: { date_filter: "last_30_days" }

    assert_response :success
    assert_includes @response.body, recent_patch.title
    assert_not_includes @response.body, older_patch.title
  end

  test "orders game patches oldest first when requested" do
    game = Game.create!(name: "Patch Sort Test", slug: "patch-sort-test")
    older_patch = game.patches.create!(
      title: "Version 1.0",
      content: "Older content",
      published_at: 40.days.ago
    )
    newer_patch = game.patches.create!(
      title: "Version 2.0",
      content: "Newer content",
      published_at: 3.days.ago
    )

    get game_url(game), params: { sort: "oldest" }

    assert_response :success
    assert_operator @response.body.index(older_patch.title), :<, @response.body.index(newer_patch.title)
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

  test "filters games by single-player flag" do
    solo_game = Game.create!(name: "Resident Evil Requiem", slug: "resident-evil-requiem", single_player: true)
    multiplayer_game = Game.create!(name: "Marvel Rivals", slug: "marvel-rivals", multiplayer: true)

    get games_url, params: { single_player: "true" }

    assert_response :success
    assert_includes @response.body, solo_game.name
    assert_not_includes @response.body, multiplayer_game.name
  end

  test "filters games by multiplayer flag" do
    multiplayer_game = Game.create!(name: "Counter-Strike 2", slug: "counter-strike-2", multiplayer: true)
    solo_game = Game.create!(name: "Final Fantasy VII Rebirth", slug: "final-fantasy-vii-rebirth", single_player: true)

    get games_url, params: { multiplayer: "true" }

    assert_response :success
    assert_includes @response.body, multiplayer_game.name
    assert_not_includes @response.body, solo_game.name
  end

  test "combines multiplayer and free-to-play filters" do
    matching_game = Game.create!(name: "Fortnite", slug: "fortnite", free_to_play: true, multiplayer: true)
    paid_multiplayer_game = Game.create!(name: "Battlefield 6", slug: "battlefield-6", free_to_play: false, multiplayer: true)
    free_solo_game = Game.create!(name: "Genshin Impact", slug: "genshin-impact", free_to_play: true, single_player: true)

    get games_url, params: { multiplayer: "true", free_to_play: "true" }

    assert_response :success
    assert_includes @response.body, matching_game.name
    assert_not_includes @response.body, paid_multiplayer_game.name
    assert_not_includes @response.body, free_solo_game.name
  end

  test "active filters link back to the same page with that filter removed" do
    get games_url, params: { genre: "Shooter", free_to_play: "true", single_player: "true", multiplayer: "true", sort: "name", query: "apex" }

    assert_response :success
    assert_select "a[href='#{games_path(query: "apex", sort: "name", free_to_play: "true", single_player: "true", multiplayer: "true")}']", text: "Shooter"
    assert_select "a[href='#{games_path(genre: "Shooter", query: "apex", sort: "name", single_player: "true", multiplayer: "true")}']", text: "Free-to-play"
    assert_select "a[href='#{games_path(genre: "Shooter", query: "apex", sort: "name", free_to_play: "true", multiplayer: "true")}']", text: "Single player"
    assert_select "a[href='#{games_path(genre: "Shooter", query: "apex", sort: "name", free_to_play: "true", single_player: "true")}']", text: "Multiplayer"
    assert_select "a[href='#{games_path(genre: "Shooter", query: "apex", free_to_play: "true", single_player: "true", multiplayer: "true")}']", text: "A–Z"
  end

  test "shows follow button on game cards for unfollowed games" do
    game = Game.create!(name: "Fortnite", slug: "fortnite")

    get games_url

    assert_response :success
    assert_includes @response.body, "See details"
    assert_select "form[action='#{favourites_path}'] input[name='game_id'][value='#{game.id}']", count: 1
    assert_select "button[aria-label='Favourite #{game.name}'] .fa-star-o", count: 1
  end

  test "shows active follow button on game cards for followed games" do
    game = Game.create!(name: "Apex Legends", slug: "apex-legends")
    favourite = @user.favourites.create!(game: game)

    get games_url

    assert_response :success
    assert_includes @response.body, "View updates"
    assert_select "form[action='#{favourite_path(favourite)}'] input[name='_method'][value='delete']", count: 1
    assert_select "button[aria-label='Unfavourite #{game.name}'].game-card__follow-btn--active .fa-star", count: 1
  end

  test "creates a game suggestion from the games page" do
    assert_difference("GameSuggestion.count", 1) do
      post suggest_games_url, params: { game_suggestion: { name: "Stardew Valley" } }
    end

    assert_redirected_to games_url
    follow_redirect!
    assert_includes @response.body, "Thanks. We have saved your game suggestion."
    assert_equal "Stardew Valley", GameSuggestion.order(:created_at).last.name
  end

  test "re-renders the games page when a game suggestion is invalid" do
    assert_no_difference("GameSuggestion.count") do
      post suggest_games_url, params: { game_suggestion: { name: "" } }
    end

    assert_response :unprocessable_entity
    assert_includes @response.body, "Name can&#39;t be blank"
    assert_select "details[open]"
  end
end
