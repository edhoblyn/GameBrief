require "anthropic"

class EventSummaryService
  def initialize(event)
    @event = event
  end

  def call
    return if @event.ai_summary_source.blank?

    client = Anthropic::Client.new

    message = client.messages.create(
      model: :"claude-opus-4-6",
      max_tokens: 256,
      messages: [
        {
          role: "user",
          content: "Write a short 1-2 sentence summary of this gaming event for a casual player. Focus on why it matters and avoid hypey filler.\n\n#{@event.ai_summary_source}"
        }
      ]
    )

    message.content.find { |block| block.type == :text }&.text&.strip
  end
end
