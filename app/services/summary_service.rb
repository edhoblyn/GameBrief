require "anthropic"

class SummaryService
  def initialize(patch)
    @patch = patch
  end

  def call
    client = Anthropic::Client.new

    message = client.messages.create(
      model: :"claude-opus-4-6",
      max_tokens: 1024,
      thinking: { type: "adaptive" },
      messages: [
        {
          role: "user",
          content: "Summarize the following game patch notes in 2-3 clear sentences for players:\n\nPatch: #{@patch.title}\n\n#{@patch.content}"
        }
      ]
    )

    message.content.find { |block| block.type == :text }&.text
  end
end
