require "open-uri"
require "nokogiri"

class Scrapers::StarWarsBattlefront2Scraper
  include Scrapers::PublishedAtExtraction
  include Scrapers::StructuredContentExtraction

  INDEX_URL = "https://www.ea.com/games/starwars/news"
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
  GAME_LABEL = "STAR WARS™ Battlefront™ II".freeze
  TITLE_PATTERN = /(free content|roadmap|what(?:'|’)s new|clone commando|capital supremacy|night on endor|launches on|update|coming|arrives)/i

  def call
    fetch_patch_cards.map do |card|
      fetch_patch(card)
    end.compact
  end

  private

  def fetch_document(url)
    Nokogiri::HTML(URI.open(url, HEADERS))
  end

  def fetch_patch_cards
    doc = fetch_document(INDEX_URL)

    doc.css("ea-tile").filter_map do |card|
      next unless card["eyebrow-text"].to_s == GAME_LABEL

      title = card["title-text"].to_s.squish
      next if title.blank? || !title.match?(TITLE_PATTERN)

      cta = card.at_css("ea-cta[link-url]")
      next if cta.nil?

      source_url = normalize_url(cta["link-url"])
      next if source_url.blank?

      {
        title: title,
        source_url: source_url,
        published_at: parse_card_date(card["eyebrow-secondary-text"])
      }
    end
  end

  def fetch_patch(card)
    doc = fetch_document(card[:source_url])
    title = doc.at("h1")&.text&.squish.presence || card[:title]
    content = extract_content(doc, title: title)
    return nil if title.blank? || content.blank?

    {
      title: title,
      content: content,
      source_url: card[:source_url],
      published_at: extract_published_at(doc) || card[:published_at]
    }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "StarWarsBattlefront2Scraper: failed to fetch #{card[:source_url]} - #{e.message}"
    nil
  end

  def extract_content(doc, title:)
    extract_structured_content(doc, selectors: [
      "main",
      "article",
      "[class*='article']",
      "[class*='content']"
    ], title: title)
  end

  def normalize_url(href)
    return if href.blank?
    return href if href.start_with?("http")

    URI.join(INDEX_URL, href).to_s
  end

  def parse_card_date(value)
    return if value.blank?

    Time.zone.parse(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end
end
