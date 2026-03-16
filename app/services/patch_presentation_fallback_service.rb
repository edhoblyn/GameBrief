class PatchPresentationFallbackService
  DEFAULT_SECTION_TITLE = "Patch Details".freeze

  def initialize(text)
    @text = text.to_s
  end

  def call
    lines = normalized_lines
    intro_lines, sections = extract_sections(lines)

    if sections.empty? && lines.any?
      sections = [build_section(DEFAULT_SECTION_TITLE, lines)].compact
    end

    {
      formatted_content: lines_to_markdown(intro_lines).presence,
      structured_sections: sections
    }
  end

  private

  def normalized_lines
    @text.gsub(/\r\n?/, "\n").lines.map { |line| line.strip }
  end

  def extract_sections(lines)
    intro_lines = []
    sections = []
    current_title = nil
    current_lines = []
    encountered_heading = false

    lines.each_with_index do |line, index|
      next_line = next_nonblank_line(lines, index + 1)

      if heading_line?(line, next_line)
        if current_title.present? || current_lines.any?
          sections << build_section(current_title.presence || DEFAULT_SECTION_TITLE, current_lines)
        end

        current_title = clean_heading(line)
        current_lines = []
        encountered_heading = true
        next
      end

      if encountered_heading
        current_lines << normalize_body_line(line)
      else
        intro_lines << normalize_body_line(line)
      end
    end

    if current_title.present? || current_lines.any?
      sections << build_section(current_title.presence || DEFAULT_SECTION_TITLE, current_lines)
    end

    [intro_lines, sections.compact]
  end

  def next_nonblank_line(lines, start_index)
    lines[start_index..]&.find(&:present?)
  end

  def heading_line?(line, next_line)
    return false if line.blank? || bullet_line?(line)

    heading = clean_heading(line)
    return false if heading.blank? || heading.length > 80
    return false if heading.split.size > 8
    return false if heading.match?(/[.!?]\z/)
    return false if next_line.blank?

    line.start_with?("#") || bullet_line?(next_line)
  end

  def clean_heading(line)
    line.to_s.sub(/\A#+\s*/, "").sub(/:\z/, "").strip
  end

  def normalize_body_line(line)
    return "" if line.blank?
    return "- #{line.sub(/\A[-*]\s+/, "").strip}" if bullet_line?(line)

    line
  end

  def bullet_line?(line)
    line.start_with?("- ", "* ")
  end

  def build_section(title, lines)
    content = lines_to_markdown(lines)
    return if content.blank?

    {
      "title" => title,
      "summary" => build_summary(lines),
      "content" => content
    }
  end

  def lines_to_markdown(lines)
    cleaned_lines = []

    Array(lines).each do |line|
      value = line.to_s.strip

      if value.blank?
        cleaned_lines << "" unless cleaned_lines.last == ""
      else
        cleaned_lines << value
      end
    end

    cleaned_lines.shift while cleaned_lines.first == ""
    cleaned_lines.pop while cleaned_lines.last == ""

    cleaned_lines.join("\n")
  end

  def build_summary(lines)
    preview = Array(lines).find(&:present?).to_s.sub(/\A[-*]\s+/, "").strip
    return if preview.blank?

    preview.length > 140 ? "#{preview.first(137)}..." : preview
  end
end
