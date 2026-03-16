require "open-uri"
require "nokogiri"

class Scrapers::ArcRaidersScraper
  include Scrapers::PublishedAtExtraction
  include Scrapers::StructuredContentExtraction

  BASE_URL = "https://arcraiders.com".freeze
  INDEX_URL = "#{BASE_URL}/news".freeze
  HEADERS = {
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
  }.freeze
  PATCH_TAG = "Patch Notes".freeze
  RECENT_WINDOW = 6.months.freeze

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

    doc.css("a[class*='news-article-card_container']").filter_map do |card|
      next unless patch_card?(card)

      source_url = normalize_url(card["href"])
      next if source_url.blank?

      published_at = parse_published_at(card.at_css("[class*='news-article-card_date']")&.text)
      next if published_at.present? && published_at < RECENT_WINDOW.ago.beginning_of_day

      {
        title: card.at_css("[class*='news-article-card_title']")&.text&.squish,
        source_url: source_url,
        published_at: published_at
      }
    end
  end

  def patch_card?(card)
    tags = card.css("[class*='news-article-card_tags'] [data-text], [class*='news-article-card_tags'] a, [class*='news-article-card_tags'] div")
      .map { |node| node.text.to_s.squish }
      .reject(&:blank?)

    tags.include?(PATCH_TAG)
  end

  def fetch_patch(card)
    doc = fetch_document(card[:source_url])
    title = doc.at_css("h1[class*='news-article-page_title']")&.text&.squish.presence || card[:title]
    content = extract_structured_content(doc, selectors: [
      ".payload-richtext",
      "[class*='article_article']"
    ], title: title)
    return nil if title.blank? || content.blank?

    {
      title: title,
      content: content,
      source_url: card[:source_url],
      published_at: extract_detail_date(doc) || extract_published_at(doc) || card[:published_at]
    }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "ArcRaidersScraper: failed to fetch #{card[:source_url]} - #{e.message}"
    nil
  end

  def extract_detail_date(doc)
    parse_published_at(doc.at_css("[class*='news-article-page_header'] > div:last-child")&.text)
  end

  def normalize_url(href)
    return if href.blank?
    return href if href.start_with?("http")

    URI.join(BASE_URL, href).to_s
  end
end
