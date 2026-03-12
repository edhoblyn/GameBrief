require "test_helper"

class Admin::PatchScrapesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = User.create!(email: "admin-scrape@test.com", password: "123456", role: "admin")
    @user = User.create!(email: "non-admin-scrape@test.com", password: "123456", role: "user")
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

  test "shows an alert for an unknown source" do
    sign_in @admin

    post admin_patch_scrapes_url, params: { source: "unknown" }

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Unknown scrape source."
  end

  test "shows a friendly alert when fortnite is blocked by the source site" do
    sign_in @admin
    original_run = PatchScrapeRunner.method(:run)
    http_error = OpenURI::HTTPError.new("403 Forbidden", StringIO.new)
    http_error.io.define_singleton_method(:status) { ["403", "Forbidden"] }

    PatchScrapeRunner.singleton_class.define_method(:run) do |_source|
      raise http_error
    end

    begin
      post admin_patch_scrapes_url, params: { source: "fortnite" }
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run, original_run)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Fortnite scrape is currently blocked by the official source site"
  end

  test "run all stores scrape diagnostics and redirects to dashboard" do
    sign_in @admin
    original_run_all = PatchScrapeRunner.method(:run_all_with_diagnostics)
    diagnostics = [
      PatchScrapeRunner::Diagnostic.new(source: "apex_legends", label: "Apex Legends", imported: 2, skipped: 1, success: true, error_message: nil, timestamp: Time.current),
      PatchScrapeRunner::Diagnostic.new(source: "fortnite", label: "Fortnite", imported: 0, skipped: 0, success: false, error_message: "403 Forbidden", timestamp: Time.current)
    ]

    PatchScrapeRunner.singleton_class.define_method(:run_all_with_diagnostics) do
      diagnostics
    end

    begin
      post run_all_admin_patch_scrapes_url
    ensure
      PatchScrapeRunner.singleton_class.define_method(:run_all_with_diagnostics, original_run_all)
    end

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_includes @response.body, "Latest run output"
    assert_includes @response.body, "403 Forbidden"
  end
end
