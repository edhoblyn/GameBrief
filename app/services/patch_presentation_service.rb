class PatchPresentationService
  class InvalidResponseError < StandardError; end

  def initialize(patch, client: nil)
    @patch = patch
    @client = client
  end

  def call
    payload = normalize_payload(parse_payload(raw_response))

    @patch.update_columns(
      formatted_content: payload[:formatted_content],
      structured_sections: payload[:structured_sections],
      ai_presentation_generated_at: Time.current,
      ai_presentation_error: nil
    )
  rescue StandardError => e
    @patch.update_columns(ai_presentation_error: e.message.to_s.first(500))
    raise
  end

  private

  def raw_response
    return @client.call(prompt) if @client.respond_to?(:call)

    RubyLLM.chat(model: "gpt-4o-mini")
            .with_instructions(instructions)
            .ask(prompt)
            .content
  end

  def instructions
    <<~PROMPT
      You are reorganising official game patch notes for GameBrief.

      Do not invent features, dates, balance values, or explanations that are not present in the source text.
      Keep the meaning faithful to the source, but improve clarity and grouping.
      Return valid JSON only. Do not wrap the JSON in markdown fences.
    PROMPT
  end

  def prompt
    <<~PROMPT
      Convert these raw patch notes into structured JSON for a patch page.

      Return exactly this shape:
      {
        "formatted_content": "Short markdown intro with 1-2 sentences summarising the overall update.",
        "structured_sections": [
          {
            "title": "Section title",
            "summary": "Optional one-sentence preview for the dropdown header.",
            "content": "Markdown body for this section. Use short paragraphs and bullet lists where useful."
          }
        ]
      }

      Rules:
      - Create between 2 and 8 sections when possible.
      - Group related notes together under clear player-friendly titles.
      - Preserve important numbers and named features from the source.
      - If the source is short, still return at least 1 section.

      Patch title: #{@patch.title}
      Game: #{@patch.game.name}
      Source URL: #{@patch.source_url}

      Raw patch notes:
      #{@patch.content}
    PROMPT
  end

  def parse_payload(raw)
    text = raw.to_s.strip
    text = text.gsub(/\A```json\s*/i, "").gsub(/\s*```\z/, "")
    JSON.parse(text)
  rescue JSON::ParserError => e
    raise InvalidResponseError, "AI returned invalid JSON: #{e.message}"
  end

  def normalize_payload(payload)
    sections = Array(payload["structured_sections"]).filter_map do |section|
      title = section["title"].to_s.strip
      content = section["content"].to_s.strip
      next if title.blank? || content.blank?

      {
        "title" => title.first(120),
        "summary" => section["summary"].to_s.strip.first(240),
        "content" => content
      }
    end

    raise InvalidResponseError, "AI returned no usable sections" if sections.empty?

    {
      formatted_content: payload["formatted_content"].to_s.strip.presence,
      structured_sections: sections
    }
  end
end
