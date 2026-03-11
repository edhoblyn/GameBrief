require "open-uri"
require "nokogiri"

class Scrapers::ClashRoyaleScraper
  include Scrapers::PublishedAtExtraction

  INDEX_URL = "https://supercell.com/en/games/clashroyale/blog/"
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
  TITLE_PATTERN = /(balance|update|maintenance|bug fix|patch|fixes)/i
  LOOKBACK_WINDOW = 6.months

  def call
    patch_links = fetch_patch_links
    Rails.logger.info "ClashRoyaleScraper: found #{patch_links.size} patches to import"
    patch_links.map { |patch_link| fetch_patch(patch_link) }.compact
  end

  private

  def fetch_patch_links
    doc = Nokogiri::HTML(URI.open(INDEX_URL, HEADERS))
    payload = extract_next_data(doc)
    return [] unless payload

    articles = payload.dig("props", "pageProps", "articles") || []
    cutoff = LOOKBACK_WINDOW.ago

    articles.filter_map do |article|
      href = article["linkUrl"].to_s.strip
      title = article["title"].to_s.squish
      published_at = parse_published_at(article["publishDate"])

      next if href.blank? || title.blank?
      next if published_at && published_at < cutoff
      next unless href.include?("/games/clashroyale/blog/")
      next unless title.match?(TITLE_PATTERN)

      {
        url: normalize_url(href),
        published_at: published_at
      }
    end.uniq
  end

  def fetch_patch(patch_link)
    url = patch_link.fetch(:url)
    doc = Nokogiri::HTML(URI.open(url, HEADERS))
    title = doc.at("h1, h2")&.text&.squish
    content = extract_content(doc)

    return nil if title.blank? || content.blank?
    return nil unless title.match?(TITLE_PATTERN)

    {
      title: title,
      content: content,
      source_url: url,
      published_at: extract_published_at(doc) || patch_link[:published_at]
    }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "ClashRoyaleScraper: failed to fetch #{url} - #{e.message}"
    nil
  end

  def extract_content(doc)
    selectors = [
      "main",
      "article",
      "[class*='article']",
      "[class*='content']"
    ]

    selectors.each do |selector|
      node = doc.at(selector)
      text = node&.text&.squish
      return text if text.present?
    end

    doc.text.to_s.squish
  end

  def normalize_url(href)
    return href if href.start_with?("http")

    URI.join(INDEX_URL, href).to_s
  end

  def extract_next_data(doc)
    script = doc.at("script#__NEXT_DATA__")
    return if script.blank?

    JSON.parse(script.text)
  rescue JSON::ParserError
    nil
  end

end
