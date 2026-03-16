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
    assert_includes @response.body, "Overwatch 2"
    assert_includes @response.body, "Pokémon Pokopia"
    assert_includes @response.body, "Resident Evil Requiem"
    assert_includes @response.body, "GTA 5: Online"
    assert_includes @response.body, "overwatch_2"
    assert_includes @response.body, "pokemon_pokopia"
    assert_includes @response.body, "gta_5_online"
    assert_includes @response.body, "Active Admin"
    assert_includes @response.body, "AI chat history"
    assert_select "form[action='#{admin_patch_scrapes_path}']", minimum: 1
    assert_select "form[action='#{admin_patch_scrapes_path}'] button", text: "Run scrape", minimum: 1
    assert_select "button[disabled]", text: "AI", minimum: 1
    assert_select "form[action='#{admin_chat_history_path}']"
  end

  test "forbids non-admin users" do
    sign_in @user

    get admin_dashboard_url

    assert_response :forbidden
  end
end
