require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "viewer@test.com", password: "123456", role: "user")
    @other_user = User.create!(email: "other@test.com", password: "123456", role: "admin", username: "OtherUser")
    sign_in @user
  end

  test "shows a user profile page" do
    get user_url(@other_user)

    assert_response :success
    assert_includes @response.body, @other_user.display_name
    assert_includes @response.body, @other_user.email
  end
end
