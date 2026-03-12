require "test_helper"

class GameTest < ActiveSupport::TestCase
  test "requires unique name ignoring case" do
    Game.create!(name: "Marvel Rivals", slug: "marvel-rivals")
    duplicate = Game.new(name: "marvel rivals", slug: "marvel-rivals-2")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "requires unique slug" do
    Game.create!(name: "Marvel Rivals", slug: "marvel-rivals")
    duplicate = Game.new(name: "Marvel Rivals 2", slug: "marvel-rivals")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "free_to_play_only returns only free-to-play games when enabled" do
    free_game = Game.create!(name: "Fortnite", slug: "fortnite", free_to_play: true)
    paid_game = Game.create!(name: "Helldivers 2", slug: "helldivers-2", free_to_play: false)

    filtered_games = Game.free_to_play_only("true")

    assert_includes filtered_games, free_game
    assert_not_includes filtered_games, paid_game
  end

  test "free_to_play_only returns all games when filter is not enabled" do
    free_game = Game.create!(name: "Fortnite", slug: "fortnite", free_to_play: true)
    paid_game = Game.create!(name: "Helldivers 2", slug: "helldivers-2", free_to_play: false)

    filtered_games = Game.free_to_play_only(nil)

    assert_includes filtered_games, free_game
    assert_includes filtered_games, paid_game
  end
end
