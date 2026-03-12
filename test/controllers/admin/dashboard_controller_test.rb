require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = User.create!(email: "admin-dashboard@test.com", password: "123456", role: "admin")
    @user = User.create!(email: "user-dashboard@test.com", password: "123456", role: "user")
  end

  test "shows the admin panel for admins" do
    sign_in @admin

    get admin_dashboard_url

    assert_response :success
    assert_includes @response.body, "Admin Panel"
    assert_includes @response.body, "Patch scrapes"
    assert_includes @response.body, "Run all scrapes"
    assert_includes @response.body, "Active Admin"
    assert_select "form[action='#{admin_patch_scrapes_path}']", minimum: 1
  end

  test "forbids non-admin users" do
    sign_in @user

    get admin_dashboard_url

    assert_response :forbidden
  end
end
