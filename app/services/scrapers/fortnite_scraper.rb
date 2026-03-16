require "open-uri"
require "nokogiri"

class Scrapers::FortniteScraper
  include Scrapers::PublishedAtExtraction
  include Scrapers::StructuredContentExtraction

  INDEX_URL = "https://www.fortnite.com/news"
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
  TITLE_PATTERN = /(fortnite battle royale|battle royale|patch notes|update)/i

  def call
    patch_links = fetch_patch_links
    Rails.logger.info "FortniteScraper: found #{patch_links.size} patches to import"
    patch_links.map { |url| fetch_patch(url) }.compact
  end

  private

  def fetch_patch_links
    doc = Nokogiri::HTML(URI.open(INDEX_URL, HEADERS))

    doc.css("a[href]").filter_map do |link|
      href = link["href"].to_s.strip
      text = link.text.to_s.squish
      next if href.blank? || text.blank?
      next unless href.include?("/news/")
      next unless text.match?(TITLE_PATTERN)

      normalize_url(href)
    end.uniq
  end

  def fetch_patch(url)
    doc = Nokogiri::HTML(URI.open(url, HEADERS))
    title = doc.at("h1")&.text&.squish
    content = extract_content(doc, title: title)

    return nil if title.blank? || content.blank?
    return nil unless title.match?(TITLE_PATTERN)

    { title: title, content: content, source_url: url, published_at: extract_published_at(doc) }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "FortniteScraper: failed to fetch #{url} - #{e.message}"
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
    return href if href.start_with?("http")

    URI.join(INDEX_URL, href).to_s
  end
end
