require "anthropic"

class SummaryService
  PROMPTS = {
    "quick_summary" => "Summarize the following game patch notes in 2-3 clear sentences for players:",
    "casual_impact" => "Based on these patch notes, explain in 2-3 sentences what actually changes for a casual player who plays a few hours a week. Focus on gameplay feel, not numbers:",
    "should_i_log_in" => "Based on these patch notes, answer the question 'Should I log in this week?' in 2-3 sentences. Be direct — is there something exciting enough to play for, or is it a minor patch?"
  }.freeze

  LABELS = {
    "quick_summary" => "Quick Summary",
    "casual_impact" => "Casual Impact",
    "should_i_log_in" => "Should I Log In?"
  }.freeze

  def initialize(patch, summary_type)
    @patch = patch
    @summary_type = summary_type
  end

  def call
    client = Anthropic::Client.new
    prompt = PROMPTS.fetch(@summary_type, PROMPTS["quick_summary"])

    message = client.messages.create(
      model: :"claude-opus-4-6",
      max_tokens: 1024,
      messages: [
        {
          role: "user",
          content: "#{prompt}\n\nPatch: #{@patch.title}\n\n#{@patch.content}"
        }
      ]
    )

    message.content.find { |block| block.type == :text }&.text
  end
end
