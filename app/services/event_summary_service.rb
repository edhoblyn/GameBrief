require "anthropic"

class EventSummaryService
  def initialize(event)
    @event = event
  end

  def call
    client = Anthropic::Client.new

    message = client.messages.create(
      model: :"claude-opus-4-6",
      max_tokens: 256,
      messages: [
        {
          role: "user",
          content: "Write a single sentence summarising this gaming event for a casual player. Be concise and exciting.\n\nEvent: #{@event.title}\n#{@event.description}"
        }
      ]
    )

    message.content.find { |block| block.type == :text }&.text
  end
end
