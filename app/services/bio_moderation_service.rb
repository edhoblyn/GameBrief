require "anthropic"

class BioModerationService
  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a content moderation assistant for a gaming community platform.
    Your job is to review user profile bios and determine if they contain harmful content.

    Harmful content includes: hate speech, slurs, threats, sexual content, self-harm promotion,
    harassment, or any content that would be inappropriate in a public gaming community.

    Respond with valid JSON only, no other text.
    Format: {"safe": true} or {"safe": false, "reason": "brief reason"}
  PROMPT

  def initialize(bio)
    @bio = bio
  end

  def safe?
    return true if @bio.blank?

    client = Anthropic::Client.new
    response = client.messages.create(
      model: :"claude-haiku-4-5-20251001",
      max_tokens: 64,
      system: SYSTEM_PROMPT,
      messages: [{ role: "user", content: "Review this profile bio: #{@bio}" }]
    )

    result = JSON.parse(response.content.first.text)
    result["safe"] == true
  rescue StandardError
    # If moderation check fails, allow the bio through rather than blocking the user
    true
  end
end
