module ApplicationHelper
  def render_markdown(text)
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true, fenced_code_blocks: true)
    markdown.render(text.to_s).html_safe
  end

  def render_patch_notes(text)
    lines = text.to_s.gsub(/\r\n?/, "\n").lines.map(&:strip)
    blocks = []
    current_list = []
    current_paragraph = []

    flush_list = lambda do
      next if current_list.empty?

      items = safe_join(current_list.map { |item| content_tag(:li, item) })
      blocks << content_tag(:ul, items, class: "patch-show__notes-list")
      current_list = []
    end

    flush_paragraph = lambda do
      next if current_paragraph.empty?

      blocks << content_tag(:p, current_paragraph.join(" "), class: "patch-show__notes-paragraph")
      current_paragraph = []
    end

    lines.each do |line|
      if line.blank?
        flush_list.call
        flush_paragraph.call
        next
      end

      if line.start_with?("- ", "* ")
        flush_paragraph.call
        current_list << line.sub(/\A[-*]\s+/, "")
        next
      end

      if section_heading?(line, lines)
        flush_list.call
        flush_paragraph.call
        blocks << content_tag(:h3, line, class: "patch-show__notes-heading")
        next
      end

      flush_list.call
      current_paragraph << line
    end

    flush_list.call
    flush_paragraph.call

    if blocks.empty?
      content_tag(:p, text.to_s, class: "patch-show__notes-paragraph")
    else
      safe_join(blocks)
    end
  end

  private

  def section_heading?(line, all_lines)
    return false if all_lines.none? { |entry| entry.start_with?("- ", "* ") }
    return false if line.length > 80
    return false if line.match?(/[.!?]\z/)
    return false if line.include?(":")

    true
  end
end
