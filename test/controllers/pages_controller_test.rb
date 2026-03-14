require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "pages-controller@test.com", password: "123456")
    sign_in @user
  end

  test "highlights my games in the loadout menu on my games page" do
    get my_games_url

    assert_response :success
    assert_select "a[href='#{my_games_path}'].profile-sidebar__nav-link--active", text: /My Games/
    assert_select "a[href='#{my_profile_path}'].profile-sidebar__nav-link--active", count: 0
  end

  test "highlights find friends in the loadout menu on find friends page" do
    get find_friends_url

    assert_response :success
    assert_select "a[href='#{find_friends_path}'].profile-sidebar__nav-link--active", text: /Find friends/
    assert_select "a[href='#{my_profile_path}'].profile-sidebar__nav-link--active", count: 0
  end

  test "shows logout button in the shared top-right settings menu" do
    get my_games_url

    assert_response :success
    assert_select "form.app-settings-menu__logout-form[action='#{destroy_user_session_path}'] button.app-settings-menu__logout.logout-btn[aria-label='Log out'][title='Log out']", text: /Log out/
    assert_select "button.app-settings-menu__logout.logout-btn i.fa.fa-sign-out"
  end
end
