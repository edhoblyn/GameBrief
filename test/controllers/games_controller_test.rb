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
end
