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
    assert_select "a[href='#{my_games_path}'].hn-dropdown-menu__link--active", text: /My Games/
    assert_select "a[href='#{my_profile_path}'].hn-dropdown-menu__link--active", count: 0
  end

  test "highlights find friends in the loadout menu on find friends page" do
    get find_friends_url

    assert_response :success
    assert_select "a[href='#{find_friends_path}'].hn-dropdown-menu__link--active", text: /Find friends/
    assert_select "a[href='#{my_profile_path}'].hn-dropdown-menu__link--active", count: 0
  end

  test "shows logout button in the shared top-right settings menu" do
    get my_games_url

    assert_response :success
    assert_select "form.app-settings-menu__logout-form[action='#{destroy_user_session_path}'] button.app-settings-menu__logout.logout-btn[aria-label='Log out'][title='Log out']", text: /Log out/
    assert_select "button.app-settings-menu__logout.logout-btn i.fa.fa-sign-out"
  end

  test "shows a sound effects mute toggle in the shared top-right settings menu" do
    get my_games_url

    assert_response :success
    assert_select "button.app-settings-menu__sound-button[data-sound-toggle][aria-label='Sound effects on'][title='Sound effects on'][aria-pressed='false']"
    assert_select "button.app-settings-menu__sound-button i.app-settings-menu__sound-icon.fa-solid.fa-volume"
  end

  test "does not render the shared spacer on the homepage" do
    get root_url

    assert_response :success
    assert_select ".app-layout-spacer", count: 0
    assert_select ".home-landing__heading", text: /Stay in the loop/i
  end

  test "keeps the shared spacer on non-home pages" do
    get my_games_url

    assert_response :success
    assert_select ".app-layout-spacer", count: 1
  end
end
