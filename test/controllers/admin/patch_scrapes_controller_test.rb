require "test_helper"

class Admin::PatchScrapesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  setup do
    @admin = User.create!(email: "admin-scrape@test.com", password: "123456", role: "admin")
    @user = User.create!(email: "non-admin-scrape@test.com", password: "123456", role: "user")
    ActiveJob::Base.queue_adapter = :test
    clear_enqueued_jobs
    clear_performed_jobs
    AdminPatchScrapeLogStore.clear(@admin)
  end

  test "forbids non-admin users" do
    sign_in @user

    post admin_patch_scrapes_url, params: { source: "apex_legends" }

    assert_response :forbidden
  end

  test "runs scrape for admins" do
    sign_in @admin
    result = PatchScrapeRunner::Result.new(source: "apex_legends", label: "Apex Legends", imported: 3, skipped: 1)
    original_run = PatchScrapeRunner.method(:run)

    PatchScrapeRunner.singleton_class.define_method(:run) do |_source|
      result
    end

    begin
      post admin_patch_scrapes_url, params: { source: "apex_legends" }
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run, original_run)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Apex Legends scrape finished: 3 imported, 1 skipped."
  end

  test "runs arc raiders scrape for admins" do
    sign_in @admin
    result = PatchScrapeRunner::Result.new(source: "arc_raiders", label: "ARC Raiders", imported: 5, skipped: 2)
    original_run = PatchScrapeRunner.method(:run)

    PatchScrapeRunner.singleton_class.define_method(:run) do |_source|
      result
    end

    begin
      post admin_patch_scrapes_url, params: { source: "arc_raiders" }
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run, original_run)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "ARC Raiders scrape finished: 5 imported, 2 skipped."
  end

  test "runs battlefield 6 scrape for admins" do
    sign_in @admin
    result = PatchScrapeRunner::Result.new(source: "battlefield_6", label: "Battlefield 6", imported: 4, skipped: 2)
    original_run = PatchScrapeRunner.method(:run)

    PatchScrapeRunner.singleton_class.define_method(:run) do |_source|
      result
    end

    begin
      post admin_patch_scrapes_url, params: { source: "battlefield_6" }
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run, original_run)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Battlefield 6 scrape finished: 4 imported, 2 skipped."
  end

  test "runs baldur's gate 3 scrape for admins" do
    sign_in @admin
    result = PatchScrapeRunner::Result.new(source: "baldurs_gate_3", label: "Baldur's Gate 3", imported: 6, skipped: 1)
    original_run = PatchScrapeRunner.method(:run)

    PatchScrapeRunner.singleton_class.define_method(:run) do |_source|
      result
    end

    begin
      post admin_patch_scrapes_url, params: { source: "baldurs_gate_3" }
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run, original_run)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Baldur&#39;s Gate 3 scrape finished: 6 imported, 1 skipped."
  end

  test "runs genshin impact scrape for admins" do
    sign_in @admin
    result = PatchScrapeRunner::Result.new(source: "genshin_impact", label: "Genshin Impact", imported: 8, skipped: 2)
    original_run = PatchScrapeRunner.method(:run)

    PatchScrapeRunner.singleton_class.define_method(:run) do |_source|
      result
    end

    begin
      post admin_patch_scrapes_url, params: { source: "genshin_impact" }
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run, original_run)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Genshin Impact scrape finished: 8 imported, 2 skipped."
  end

  test "runs league of legends scrape for admins" do
    sign_in @admin
    result = PatchScrapeRunner::Result.new(source: "league_of_legends", label: "League of Legends", imported: 5, skipped: 1)
    original_run = PatchScrapeRunner.method(:run)

    PatchScrapeRunner.singleton_class.define_method(:run) do |_source|
      result
    end

    begin
      post admin_patch_scrapes_url, params: { source: "league_of_legends" }
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run, original_run)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "League of Legends scrape finished: 5 imported, 1 skipped."
  end

  test "runs counter-strike 2 scrape for admins" do
    sign_in @admin
    result = PatchScrapeRunner::Result.new(source: "counter_strike_2", label: "Counter-Strike 2", imported: 7, skipped: 2)
    original_run = PatchScrapeRunner.method(:run)

    PatchScrapeRunner.singleton_class.define_method(:run) do |_source|
      result
    end

    begin
      post admin_patch_scrapes_url, params: { source: "counter_strike_2" }
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run, original_run)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Counter-Strike 2 scrape finished: 7 imported, 2 skipped."
  end

  test "runs pubg battlegrounds scrape for admins" do
    sign_in @admin
    result = PatchScrapeRunner::Result.new(source: "pubg_battlegrounds", label: "PUBG: Battlegrounds", imported: 6, skipped: 1)
    original_run = PatchScrapeRunner.method(:run)

    PatchScrapeRunner.singleton_class.define_method(:run) do |_source|
      result
    end

    begin
      post admin_patch_scrapes_url, params: { source: "pubg_battlegrounds" }
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run, original_run)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "PUBG: Battlegrounds scrape finished: 6 imported, 1 skipped."
  end

  test "runs overwatch 2 scrape for admins" do
    sign_in @admin
    result = PatchScrapeRunner::Result.new(source: "overwatch_2", label: "Overwatch 2", imported: 4, skipped: 2)
    original_run = PatchScrapeRunner.method(:run)

    PatchScrapeRunner.singleton_class.define_method(:run) do |_source|
      result
    end

    begin
      post admin_patch_scrapes_url, params: { source: "overwatch_2" }
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run, original_run)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Overwatch 2 scrape finished: 4 imported, 2 skipped."
  end

  test "runs horizon forbidden west scrape for admins" do
    sign_in @admin
    result = PatchScrapeRunner::Result.new(source: "horizon_forbidden_west", label: "Horizon Forbidden West", imported: 6, skipped: 2)
    original_run = PatchScrapeRunner.method(:run)

    PatchScrapeRunner.singleton_class.define_method(:run) do |_source|
      result
    end

    begin
      post admin_patch_scrapes_url, params: { source: "horizon_forbidden_west" }
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run, original_run)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Horizon Forbidden West scrape finished: 6 imported, 2 skipped."
  end

  test "runs cyberpunk 2077 scrape for admins" do
    sign_in @admin
    result = PatchScrapeRunner::Result.new(source: "cyberpunk_2077", label: "Cyberpunk 2077", imported: 5, skipped: 1)
    original_run = PatchScrapeRunner.method(:run)

    PatchScrapeRunner.singleton_class.define_method(:run) do |_source|
      result
    end

    begin
      post admin_patch_scrapes_url, params: { source: "cyberpunk_2077" }
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run, original_run)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Cyberpunk 2077 scrape finished: 5 imported, 1 skipped."
  end

  test "runs spider-man 2 scrape for admins" do
    sign_in @admin
    result = PatchScrapeRunner::Result.new(source: "spider_man_2", label: "Marvel's Spider-Man 2", imported: 7, skipped: 1)
    original_run = PatchScrapeRunner.method(:run)

    PatchScrapeRunner.singleton_class.define_method(:run) do |_source|
      result
    end

    begin
      post admin_patch_scrapes_url, params: { source: "spider_man_2" }
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run, original_run)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Marvel&#39;s Spider-Man 2 scrape finished: 7 imported, 1 skipped."
  end

  test "shows an alert for an unknown source" do
    sign_in @admin

    post admin_patch_scrapes_url, params: { source: "unknown" }

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Unknown scrape source."
  end

  test "shows a friendly alert when fortnite requires alternate ingestion" do
    sign_in @admin
    post admin_patch_scrapes_url, params: { source: "fortnite" }

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Fortnite currently requires an API or alternate endpoint"
  end

  test "does not allow manual scrape runs for blocked sources" do
    sign_in @admin

    post admin_patch_scrapes_url, params: { source: "minecraft" }

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Minecraft currently requires an API or alternate endpoint"
  end

  test "run all stores scrape diagnostics and redirects to dashboard" do
    sign_in @admin
    original_run_all = PatchScrapeRunner.method(:run_all_with_diagnostics)
    diagnostics = [
      PatchScrapeRunner::Diagnostic.new(source: "apex_legends", label: "Apex Legends", imported: 2, skipped: 1, success: true, error_message: nil, timestamp: Time.current),
      PatchScrapeRunner::Diagnostic.new(source: "minecraft", label: "Minecraft", imported: 1, skipped: 0, success: true, error_message: nil, timestamp: Time.current)
    ]

    PatchScrapeRunner.singleton_class.define_method(:run_all_with_diagnostics) do
      diagnostics
    end

    begin
      assert_enqueued_with(job: RunAllPatchScrapesJob, args: [@admin.id]) do
        post run_all_admin_patch_scrapes_url
      end

      perform_enqueued_jobs
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run_all_with_diagnostics, original_run_all)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "All scrapes started in the background."
    assert_includes @response.body, "Latest run output"
    assert_includes @response.body, "Minecraft"
  end
end
