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
end
