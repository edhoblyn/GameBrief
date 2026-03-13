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

  test "filters events by selected games" do
    included_game = Game.create!(name: "Included Game", slug: "included-game")
    excluded_game = Game.create!(name: "Excluded Game", slug: "excluded-game")
    included_game.events.create!(title: "Included Event", start_date: 4.days.from_now)
    excluded_game.events.create!(title: "Excluded Event", start_date: 4.days.from_now)

    get events_url, params: { game_ids: [included_game.id] }

    assert_response :success
    assert_includes response.body, "Included Event"
    assert_not_includes response.body, "Excluded Event"
    assert_select "input[type=checkbox][name='game_ids[]'][value='#{included_game.id}'][checked='checked']", count: 1
  end

  test "preserves selected games while changing time filters" do
    game = Game.create!(name: "Persistent Game", slug: "persistent-game")
    game.events.create!(title: "Persistent Event", start_date: 2.days.from_now)

    get events_url, params: { game_ids: [game.id], time_filter: "week" }

    assert_response :success
    assert_select "a[href='#{events_path(time_filter: 'week', game_ids: [game.id])}']", text: "This week"
    assert_select "a", text: "Reset filter"
  end

  test "orders game filter options with followed games first and alphabetical within groups" do
    followed_b = Game.create!(name: "Beta Ops", slug: "beta-ops")
    followed_a = Game.create!(name: "Alpha Quest", slug: "alpha-quest")
    other_b = Game.create!(name: "Delta Run", slug: "delta-run")
    other_a = Game.create!(name: "Crimson Drift", slug: "crimson-drift")

    [followed_b, followed_a, other_b, other_a].each do |game|
      game.events.create!(title: "#{game.name} Event", start_date: 3.days.from_now)
    end

    @user.favourites.create!(game: followed_b)
    @user.favourites.create!(game: followed_a)

    get events_url

    assert_response :success
    assert_equal ["Alpha Quest", "Beta Ops", "Crimson Drift", "Delta Run"], rendered_game_filter_options.first(4)
  end

  test "shows a richer event detail page with related content and actions" do
    game = Game.create!(name: "Arena Prime", slug: "arena-prime", cover_image: "https://example.com/arena-prime.jpg")
    event = game.events.create!(
      title: "Spring Clash",
      description: "Seasonal event with limited-time rewards and playlist updates.",
      summary: "A fast seasonal beat for players who want fresh rewards and new matches.",
      start_date: 3.days.from_now
    )
    game.events.create!(title: "Qualifier Weekend", start_date: 8.days.from_now)
    patch = game.patches.create!(title: "Version 1.2", content: "Patch notes", published_at: 1.day.ago)
    @user.favourites.create!(game: game)
    @user.reminders.create!(event: event)

    get event_url(event)

    assert_response :success
    assert_includes response.body, "Spring Clash"
    assert_includes response.body, "Add to Google Calendar"
    assert_includes response.body, "Remove Reminder"
    assert_includes response.body, "Following Arena Prime"
    assert_includes response.body, "More from Arena Prime"
    assert_includes response.body, "Qualifier Weekend"
    assert_includes response.body, patch.title
    assert_includes response.body, "What is happening"
    assert_includes response.body, event.summary
  end

  test "event detail page offers summary generation when summary is missing" do
    game = Game.create!(name: "No Summary Game", slug: "no-summary-game")
    event = game.events.create!(title: "Fresh Start", description: "New event", start_date: 5.days.from_now)

    get event_url(event)

    assert_response :success
    assert_select "form[action='#{generate_summary_event_path(event)}']"
    assert_includes response.body, "Generate AI Summary"
  end

  private

  def rendered_event_titles
    Nokogiri::HTML(response.body).css(".events-index__event-title").map(&:text).map(&:strip)
  end

  def rendered_game_filter_options
    Nokogiri::HTML(response.body).css(".events-index__game-filter-option span").map(&:text).map(&:strip)
  end
end
