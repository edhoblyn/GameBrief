require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "limits user messages per chat to five" do
    game = Game.create!(name: "Message Limit Game", slug: "message-limit-game")
    patch = Patch.create!(game: game, title: "Patch", content: "Notes")
    user = User.create!(email: "message-limit@test.com", password: "123456")
    chat = Chat.create!(patch: patch, user: user)

    Message::MAX_USER_MESSAGES.times do |index|
      assert Message.create(chat: chat, role: "user", content: "Question #{index + 1}").persisted?
    end

    extra_message = Message.new(chat: chat, role: "user", content: "One more question")

    assert_not extra_message.valid?
    assert_includes extra_message.errors[:content], "You can only send #{Message::MAX_USER_MESSAGES} messages per chat."
  end
end
