require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = User.create!(email: "admin-manager@test.com", password: "123456", role: "admin")
    @user = User.create!(email: "plain-user@test.com", password: "123456", role: "user")
  end

  test "adds an existing user as an admin" do
    sign_in @admin

    post admin_users_url, params: { email: @user.email }

    assert_redirected_to admin_dashboard_path
    assert_equal "admin", @user.reload.role
  end

  test "removes an admin" do
    sign_in @admin
    second_admin = User.create!(email: "second-admin@test.com", password: "123456", role: "admin")

    delete admin_user_url(second_admin)

    assert_redirected_to admin_dashboard_path
    assert_equal "user", second_admin.reload.role
  end

  test "does not remove the last admin" do
    sign_in @admin

    delete admin_user_url(@admin)

    assert_redirected_to admin_dashboard_path
    assert_equal "admin", @admin.reload.role
  end
end
