require "test_helper"

class GenerateEventSummaryJobTest < ActiveJob::TestCase
  test "stores the generated summary on the event" do
    game = Game.create!(name: "Event Summary Job Game", slug: "event-summary-job-game")
    event = game.events.create!(
      title: "Spring Finals",
      description: "A large competitive event with new in-game drops, watch rewards, featured matches, and a full weekend schedule.",
      start_date: 3.days.from_now
    )

    service = Object.new
    service.define_singleton_method(:call) { "A concise event summary." }

    original_new = EventSummaryService.method(:new)
    EventSummaryService.define_singleton_method(:new) { |_event| service }

    GenerateEventSummaryJob.perform_now(event.id)

    assert_equal "A concise event summary.", event.reload.summary
  ensure
    EventSummaryService.define_singleton_method(:new, original_new)
  end

  test "clears the pending marker when no summary is generated" do
    game = Game.create!(name: "Event Summary Nil Job Game", slug: "event-summary-nil-job-game")
    event = game.events.create!(
      title: "Spring Finals",
      description: "A large competitive event with new in-game drops, watch rewards, featured matches, and a full weekend schedule.",
      start_date: 3.days.from_now
    )
    event.update_column(:summary_requested_at, Time.current)

    service = Object.new
    service.define_singleton_method(:call) { nil }

    original_new = EventSummaryService.method(:new)
    EventSummaryService.define_singleton_method(:new) { |_event| service }

    GenerateEventSummaryJob.perform_now(event.id)

    assert_nil event.reload.summary
    assert_nil event.summary_requested_at
  ensure
    EventSummaryService.define_singleton_method(:new, original_new)
  end
end
