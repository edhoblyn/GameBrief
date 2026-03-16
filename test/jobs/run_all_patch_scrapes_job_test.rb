require "test_helper"

class RunAllPatchScrapesJobTest < ActiveJob::TestCase
  setup do
    @admin = User.create!(email: "run-all-job-admin@test.com", password: "123456", role: "admin")
    AdminPatchScrapeLogStore.clear(@admin)
  end

  test "stores diagnostics for the requesting admin" do
    diagnostics = [
      PatchScrapeRunner::Diagnostic.new(
        source: "apex_legends",
        label: "Apex Legends",
        imported: 3,
        skipped: 1,
        success: true,
        error_message: nil,
        timestamp: Time.current
      )
    ]
    original_run_all = PatchScrapeRunner.method(:run_all_with_diagnostics)

    PatchScrapeRunner.singleton_class.define_method(:run_all_with_diagnostics) do
      diagnostics
    end

    RunAllPatchScrapesJob.perform_now(@admin.id)

    payload = AdminPatchScrapeLogStore.fetch(@admin)
    assert_equal "completed", payload["status"]
    assert_equal "Apex Legends", payload["logs"].first["label"]
    assert_equal 3, payload["logs"].first["imported"]
  ensure
    PatchScrapeRunner.singleton_class.define_method(:run_all_with_diagnostics, original_run_all)
  end
end
