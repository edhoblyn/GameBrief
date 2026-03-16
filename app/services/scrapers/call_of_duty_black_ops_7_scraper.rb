require "open-uri"
require "nokogiri"

class Scrapers::CallOfDutyBlackOps7Scraper
  include Scrapers::PublishedAtExtraction
  include Scrapers::StructuredContentExtraction

  INDEX_URL = "https://www.callofduty.com/patchnotes"
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }

  def call
    patch_links = fetch_patch_links
    Rails.logger.info "CallOfDutyBlackOps7Scraper: found #{patch_links.size} patches to import"
    patch_links.map { |url| fetch_patch(url) }.compact
  end

  private

  def fetch_patch_links
    doc = fetch_document(INDEX_URL)

    doc.css("a[href]").filter_map do |link|
      href = link["href"].to_s.strip
      text = link.text.to_s.squish
      next if href.blank?
      next unless href.include?("/patchnotes/")
      next unless text.downcase.include?("black ops")

      normalize_url(href)
    end.uniq
  end

  def fetch_patch(url)
    doc = fetch_document(url)
    title = doc.at("h1")&.text&.squish
    content = extract_content(doc, title: title)
    published_at = extract_published_at(doc) || extract_published_at_from_url(url)

    return nil if title.blank? || content.blank?

    { title: title, content: content, source_url: url, published_at: published_at }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "CallOfDutyBlackOps7Scraper: failed to fetch #{url} - #{e.message}"
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

  def fetch_document(url)
    Nokogiri::HTML(URI.open(url, HEADERS))
  end

  def normalize_url(href)
    return href if href.start_with?("http")

    URI.join(INDEX_URL, href).to_s
  end

  def extract_published_at_from_url(url)
    match = url.match(%r{/patchnotes/(\d{4})/(\d{2})(?:/(\d{2}))?/})
    return if match.nil?

    year = match[1].to_i
    month = match[2].to_i
    day = match[3].presence&.to_i || 1

    Time.zone.local(year, month, day)
  rescue ArgumentError
    nil
  end
end
