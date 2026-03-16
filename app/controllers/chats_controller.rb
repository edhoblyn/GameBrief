class ChatsController < ApplicationController
  include ActionController::Live

  before_action :set_patch

  def create
    @chat = @patch.chats.find_or_create_by(user: current_user)
    redirect_to patch_path(@patch, chat_id: @chat.id, return_to: safe_return_to_path)
  end

  def stream
    response.headers["Content-Type"]      = "text/event-stream"
    response.headers["Cache-Control"]     = "no-cache"
    response.headers["X-Accel-Buffering"] = "no"

    sse = ActionController::Live::SSE.new(response.stream, retry: 300)

    content = params[:content].to_s.strip
    if content.blank?
      sse.write({ error: "empty" }, event: "error")
      return
    end

    chat = @patch.chats.find_by!(id: params[:id], user: current_user)

    if chat.user_message_limit_reached?
      sse.write({ error: "limit" }, event: "error")
      return
    end

    user_message = chat.messages.create!(role: "user", content: content)
    sse.write(
      { user_message_count: chat.user_message_count, limit_reached: chat.user_message_limit_reached? },
      event: "accepted"
    )

    full_response = ""
    llm = ::RubyLLM.chat(model: "gpt-4o")
    chat.messages.where.not(id: user_message.id).each { |m| llm.add_message(m) }

    llm.with_instructions(instructions).ask(content) do |chunk|
      token = chunk.content.to_s
      next if token.empty?
      full_response += token
      sse.write({ token: token }, event: "token")
    end

    chat.messages.create!(role: "assistant", content: full_response)
    chat.generate_title_from_first_message
    sse.write({}, event: "done")

  rescue => e
    sse.write({ error: e.message }, event: "error") rescue nil
  ensure
    sse.close
  end

  private

  def set_patch
    @patch = Patch.find(params[:patch_id])
  end

  def instructions
    <<~PROMPT
      You are a helpful gaming assistant for GameBrief. You help casual gamers understand patch notes quickly and clearly.

      You are answering questions about the following patch: "#{@patch.title}" for the game "#{@patch.game.name}".

      Here are the patch notes:
      #{@patch.content}

      Rules for your responses:
      - Keep answers short and friendly.
      - Use bullet points or short paragraphs — never one long block of text.
      - Use **bold** to highlight the most important changes.
      - Avoid jargon. If you must use a game term, explain it in plain English.
      - End with a one-sentence takeaway when relevant.
    PROMPT
  end
end
