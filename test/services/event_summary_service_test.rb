require "test_helper"
require "uri"

class EventSummaryServiceTest < ActiveSupport::TestCase
  setup do
    EventSummaryService.reset_provider_cooldown!
  end

  teardown do
    EventSummaryService.reset_provider_cooldown!
  end

  test "disables event summaries after an Anthropic low-credit error" do
    game = Game.create!(name: "Event Summary Service Game", slug: "event-summary-service-game")
    event = game.events.create!(
      title: "Spring Finals",
      description: "A large competitive event with new in-game drops, watch rewards, featured matches, and a full weekend schedule.",
      start_date: 3.days.from_now
    )

    create_calls = 0
    error = Anthropic::Errors::BadRequestError.new(
      url: URI("https://api.anthropic.com/v1/messages"),
      status: 400,
      headers: {},
      body: {
        type: "error",
        error: {
          type: "invalid_request_error",
          message: "Your credit balance is too low to access the Anthropic API."
        },
        request_id: "req_test"
      },
      request: nil,
      response: nil
    )

    messages = Object.new
    messages.define_singleton_method(:create) do |**|
      create_calls += 1
      raise error
    end

    client = Object.new
    client.define_singleton_method(:messages) { messages }

    original_new = Anthropic::Client.method(:new)
    Anthropic::Client.define_singleton_method(:new) { client }

    assert_nil EventSummaryService.new(event).call
    assert EventSummaryService.provider_temporarily_unavailable?

    assert_nil EventSummaryService.new(event).call
    assert_equal 1, create_calls
  ensure
    Anthropic::Client.define_singleton_method(:new, original_new)
  end
end
