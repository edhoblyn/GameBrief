require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "viewer@test.com", password: "123456", role: "user")
    @admin = User.create!(email: "admin-viewer@test.com", password: "123456", role: "admin")
    @other_user = User.create!(email: "other@test.com", password: "123456", role: "user", username: "OtherUser")
  end

  test "shows the users page for admins" do
    sign_in @admin

    get users_url

    assert_response :success
    assert_includes @response.body, "Players"
    assert_includes @response.body, @user.email
    assert_includes @response.body, @other_user.display_name
  end

  test "forbids the users page for non-admins" do
    sign_in @user

    get users_url

    assert_response :forbidden
  end

  test "shows a user profile page" do
    sign_in @user

    get user_url(@other_user)

    assert_response :success
    assert_includes @response.body, @other_user.display_name
    assert_includes @response.body, @other_user.email
  end
end
