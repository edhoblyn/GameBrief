require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(
      email: "profile-edit@test.com",
      password: "123456",
      username: "OriginalName",
      avatar_url: "https://example.com/original.png"
    )
    sign_in @user
  end

  test "dashboard edit profile button links to account edit page" do
    get my_profile_url

    assert_response :success
    assert_select "a.btn-edit-profile[href='#{edit_user_registration_path}']", text: "Edit Profile"
  end

  test "updates username and avatar without requiring current password" do
    patch user_registration_url, params: {
      user: {
        username: "UpdatedName",
        avatar_url: "https://example.com/updated.png",
        email: @user.email,
        current_password: ""
      }
    }

    assert_redirected_to root_path

    @user.reload
    assert_equal "UpdatedName", @user.username
    assert_equal "https://example.com/updated.png", @user.avatar_url
  end
end
