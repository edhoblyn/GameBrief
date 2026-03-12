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

    assert_redirected_to games_path
    follow_redirect!
    assert_includes @response.body, "Apex Legends scrape finished: 3 imported, 1 skipped."
  end

  test "shows an alert for an unknown source" do
    sign_in @admin

    post admin_patch_scrapes_url, params: { source: "unknown" }

    assert_redirected_to games_path
    follow_redirect!
    assert_includes @response.body, "Unknown scrape source."
  end
end
