class MessagesController < ApplicationController
  before_action :set_patch
  before_action :set_chat

  def create
    @message = @chat.messages.new(role: "user", content: params[:message][:content])

    if @message.save
      @ruby_llm_chat = ::RubyLLM.chat(model: "gpt-4o")
      build_conversation_history
      response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content)

      @assistant_message = @chat.messages.create(role: "assistant", content: response.content)
      @chat.generate_title_from_first_message
    else
      flash[:alert] = @message.errors.full_messages.to_sentence
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append("messages", partial: "messages/messages", locals: { messages: [@message, @assistant_message].compact }),
          turbo_stream.replace("new_message_container", partial: "messages/form", locals: { patch: @patch, chat: @chat, message: Message.new })
        ]
      end
      format.html { redirect_to patch_path(@patch, chat_id: @chat.id) }
    end
  end

  private

  def set_patch
    @patch = Patch.find(params[:patch_id])
  end

  def set_chat
    @chat = @patch.chats.find(params[:chat_id])
  end

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end

  def instructions
    <<~PROMPT
      You are a helpful gaming assistant for GameBrief. You help casual gamers understand patch notes quickly and clearly.

      You are answering questions about the following patch: "#{@patch.title}" for the game "#{@patch.game.name}".

      Here are the patch notes:
      #{@patch.content}

      Keep your answers short, friendly and easy to understand for casual gamers. Avoid jargon where possible.
    PROMPT
  end
end
