require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess::FixtureFile

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

  test "uploads avatar and cover images without requiring current password" do
    patch user_registration_url, params: {
      user: {
        email: @user.email,
        current_password: "",
        avatar_image: fixture_file_upload("profile-upload.txt", "text/plain"),
        cover_image: fixture_file_upload("profile-upload.txt", "text/plain")
      }
    }

    assert_redirected_to root_path

    @user.reload
    assert @user.avatar_image.attached?
    assert @user.cover_image.attached?
  end
end
