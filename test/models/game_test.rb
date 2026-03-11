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
end
