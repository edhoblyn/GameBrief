require "test_helper"

class EventTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "is ai summarizable when it has enough source text" do
    event = Event.new(
      title: "Spring Finals",
      description: "A large competitive event with new in-game drops, watch rewards, featured matches, and a full weekend schedule."
    )

    assert event.ai_summarizable?
  end

  test "queues a summary job after commit when title or description becomes summarizable" do
    game = Game.create!(name: "Event Model Game", slug: "event-model-game")

    assert_enqueued_with(job: GenerateEventSummaryJob) do
      game.events.create!(
        title: "Spring Finals",
        description: "A large competitive event with new in-game drops, watch rewards, featured matches, and a full weekend schedule.",
        start_date: 4.days.from_now
      )
    end
  end

  test "does not queue a summary job for sparse events" do
    game = Game.create!(name: "Sparse Event Game", slug: "sparse-event-game")

    assert_no_enqueued_jobs only: GenerateEventSummaryJob do
      game.events.create!(
        title: "Teaser",
        description: "Soon.",
        start_date: 4.days.from_now
      )
    end
  end

  test "does not queue a duplicate summary job while one is already pending" do
    game = Game.create!(name: "Pending Event Game", slug: "pending-event-game")
    event = game.events.create!(
      title: "Spring Finals",
      description: "A large competitive event with new in-game drops, watch rewards, featured matches, and a full weekend schedule.",
      start_date: 4.days.from_now
    )

    clear_enqueued_jobs

    assert_not event.request_ai_summary!
    assert_no_enqueued_jobs only: GenerateEventSummaryJob
  end
end
