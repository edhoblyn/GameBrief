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

  test "single_player_only returns only single-player games when enabled" do
    solo_game = Game.create!(name: "Resident Evil 4", slug: "resident-evil-4", single_player: true)
    multiplayer_game = Game.create!(name: "Valorant", slug: "valorant", single_player: false)

    filtered_games = Game.single_player_only("true")

    assert_includes filtered_games, solo_game
    assert_not_includes filtered_games, multiplayer_game
  end

  test "multiplayer_only returns only multiplayer games when enabled" do
    multiplayer_game = Game.create!(name: "Overwatch 2", slug: "overwatch-2", multiplayer: true)
    solo_game = Game.create!(name: "Marvel's Spider-Man 2", slug: "marvels-spider-man-2", multiplayer: false)

    filtered_games = Game.multiplayer_only("true")

    assert_includes filtered_games, multiplayer_game
    assert_not_includes filtered_games, solo_game
  end

  test "genre_tags parses postgres array strings into clean labels" do
    game = Game.new(name: "Warzone", slug: "warzone")
    game[:genre] = "{\"Shooter\",\"Battle Royale\"}"

    assert_equal ["Shooter", "Battle Royale"], game.genre_tags
  end
end
