require "test_helper"

class GeneratePatchPresentationJobTest < ActiveJob::TestCase
  test "runs the patch presentation service" do
    game = Game.create!(name: "Presentation Job Game", slug: "presentation-job-game")
    patch = Patch.create!(
      game: game,
      title: "Patch 2.0",
      content: "Patch notes",
      source_url: "https://example.com/patch/2-0"
    )

    called = false
    service = Object.new
    service.define_singleton_method(:call) { called = true }

    original_new = PatchPresentationService.method(:new)
    PatchPresentationService.define_singleton_method(:new) { |_patch| service }

    GeneratePatchPresentationJob.perform_now(patch.id)

    assert called
  ensure
    PatchPresentationService.define_singleton_method(:new, original_new)
  end
end
