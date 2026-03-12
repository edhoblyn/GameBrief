module Scrapers::StructuredContentExtraction
  EXCLUDED_SELECTORS = "script, style, noscript, svg, button".freeze
  STRUCTURED_TAGS = "h1, h2, h3, h4, h5, h6, p, li".freeze
  BOILERPLATE_PATTERNS = [
    /\AFollow\z/i,
    /\AUpdated\z/i,
    /\ARelated articles\z/i,
    /\AComments\z/i,
    /\A\d+\s+comments?\z/i,
    /\AArticle is closed for comments\.?\z/i,
    /\AFacebook\z/i,
    /\ATwitter\z/i,
    /\ALinkedIn\z/i,
    /\A[A-Z][a-z]+ \d{1,2}, \d{4}(?: \d{1,2}:\d{2})?\z/
  ].freeze

  private

  def extract_structured_content(doc, selectors:, title: nil)
    selectors.each do |selector|
      node = doc.at(selector)
      next if node.blank?

      content = extract_text_blocks(node, title: title)
      return content if content.present?
    end

    extract_text_blocks(doc, title: title) || doc.text.to_s.squish
  end

  def extract_text_blocks(node, title: nil)
    cleaned_node = node.dup
    cleaned_node.css(EXCLUDED_SELECTORS).remove

    blocks = cleaned_node.css(STRUCTURED_TAGS).filter_map do |element|
      text = element.text.to_s.squish
      next if text.blank?
      next if ignore_block?(text, title: title)

      element.name == "li" ? "- #{text}" : text
    end

    blocks = blocks.each_with_object([]) do |block, items|
      items << block unless items.last == block
    end

    return if blocks.empty?

    blocks.join("\n")
  end

  def ignore_block?(text, title:)
    return true if title.present? && normalized_text(text) == normalized_text(title)

    BOILERPLATE_PATTERNS.any? { |pattern| text.match?(pattern) }
  end

  def normalized_text(text)
    text.to_s.downcase.gsub(/[^a-z0-9]+/, "")
  end
end
