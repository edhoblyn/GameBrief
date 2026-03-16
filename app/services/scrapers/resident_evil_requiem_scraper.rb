require "open-uri"
require "nokogiri"

class Scrapers::ResidentEvilRequiemScraper
  ANNOUNCEMENTS_URL = "https://steamcommunity.com/app/3764200/announcements/"
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
  TITLE_PATTERN = /(notice|update|patch|hotfix|release|support|out now)/i

  def call
    doc = fetch_document(ANNOUNCEMENTS_URL)
    announcement_cards = doc.css(".apphub_Card.Announcement_Card[data-modal-content-url]")

    Rails.logger.info "ResidentEvilRequiemScraper: found #{announcement_cards.size} announcement cards"

    announcement_cards.filter_map do |card|
      build_patch(card)
    end
  end

  private

  def fetch_document(url)
    Nokogiri::HTML(URI.open(url, HEADERS))
  end

  def build_patch(card)
    title = card.at_css(".apphub_CardContentNewsTitle")&.text&.squish
    return if title.blank? || !title.match?(TITLE_PATTERN)

    content = extract_content(card.at_css(".apphub_CardTextContent"))
    source_url = card["data-modal-content-url"].to_s.strip
    return if content.blank? || source_url.blank?

    {
      title: title,
      content: content,
      source_url: source_url,
      published_at: parse_card_date(card.at_css(".apphub_CardContentNewsDate")&.text)
    }
  end

  def extract_content(node)
    return if node.nil?

    fragment = Nokogiri::HTML::DocumentFragment.parse(node.inner_html)
    fragment.css("br").each { |line_break| line_break.replace("\n") }
    fragment.css("p").each { |paragraph| paragraph.after("\n\n") }
    fragment.css("hr").each { |rule| rule.replace("\n\n") }

    fragment.text
      .gsub("\u00A0", " ")
      .gsub(/[ \t]+\n/, "\n")
      .gsub(/\n{3,}/, "\n\n")
      .strip
  end

  def parse_card_date(value)
    return if value.blank?

    published_at = Time.zone.parse(value.to_s.squish)
    return if published_at.blank?
    return published_at if value.to_s.match?(/\b20\d{2}\b/)
    return published_at if published_at <= Time.zone.now.end_of_day

    published_at.change(year: published_at.year - 1)
  rescue ArgumentError, TypeError
    nil
  end
end
