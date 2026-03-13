require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "events-controller@test.com", password: "123456")
    sign_in @user
  end

  test "shows upcoming events and summary cards on index" do
    game = Game.create!(name: "Summary Game", slug: "summary-game")
    game.events.create!(title: "Next Event", start_date: 2.days.from_now)
    game.events.create!(title: "Past Event", start_date: 2.days.ago)

    get events_url

    assert_response :success
    assert_includes response.body, "Track what is happening next across the games you care about."
    assert_includes response.body, "Upcoming events"
    assert_includes response.body, "Next Event"
    assert_not_includes response.body, "Past Event"
  end

  test "filters events to the requested time range" do
    game = Game.create!(name: "Filter Game", slug: "filter-game")
    this_week_event = game.events.create!(title: "This Week Event", start_date: 2.days.from_now)
    this_month_event = game.events.create!(title: "This Month Event", start_date: 12.days.from_now)
    future_event = game.events.create!(title: "Future Event", start_date: 40.days.from_now)

    get events_url, params: { time_filter: "week" }

    assert_response :success
    assert_includes response.body, this_week_event.title
    assert_not_includes response.body, this_month_event.title
    assert_not_includes response.body, future_event.title
  end

  test "surfaces followed game events first in each timeline group" do
    followed_game = Game.create!(name: "Followed Game", slug: "followed-game")
    other_game = Game.create!(name: "Other Game", slug: "other-game")
    @user.favourites.create!(game: followed_game)

    followed_event = followed_game.events.create!(title: "Followed Event", start_date: 3.days.from_now)
    other_event = other_game.events.create!(title: "Other Event", start_date: 3.days.from_now)

    get events_url

    assert_response :success
    assert_equal ["Followed Event", "Other Event"], rendered_event_titles.first(2)
    assert_includes response.body, "Following"
    assert_includes response.body, followed_event.title
    assert_includes response.body, other_event.title
  end

  private

  def rendered_event_titles
    Nokogiri::HTML(response.body).css(".events-index__event-title").map(&:text).map(&:strip)
  end
end
