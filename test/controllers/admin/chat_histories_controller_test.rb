require "test_helper"

class Admin::ChatHistoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = User.create!(email: "admin-chat-history@test.com", password: "123456", role: "admin")
    @user = User.create!(email: "user-chat-history@test.com", password: "123456", role: "user")
    @patch = Patch.create!(
      title: "Demo Patch",
      content: "Patch notes",
      game: Game.create!(name: "Demo Game")
    )
  end

  test "forbids non-admin users" do
    sign_in @user

    delete admin_chat_history_url

    assert_response :forbidden
  end

  test "clears all chats and messages for admins" do
    sign_in @admin
    chat = Chat.create!(patch: @patch, user: @user)
    Message.create!(chat: chat, role: "user", content: "Question")
    Message.create!(chat: chat, role: "assistant", content: "Answer")

    delete admin_chat_history_url

    assert_redirected_to admin_dashboard_path
    assert_equal 0, Chat.count
    assert_equal 0, Message.count

    follow_redirect!
    assert_includes @response.body, "AI chat history cleared: 1 chats and 2 messages removed."
  end
end
