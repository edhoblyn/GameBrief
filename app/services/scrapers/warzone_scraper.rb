require "open-uri"
require "nokogiri"

class Scrapers::WarzoneScraper
  INDEX_URL = "https://www.callofduty.com/patchnotes"
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }

  def call
    patch_links = fetch_patch_links
    Rails.logger.info "WarzoneScraper: found #{patch_links.size} patches to import"
    patch_links.map { |url| fetch_patch(url) }.compact
  end

  private

  def fetch_patch_links
    doc = Nokogiri::HTML(URI.open(INDEX_URL, HEADERS))

    doc.css("a[href]").filter_map do |link|
      href = link["href"].to_s.strip
      text = link.text.to_s.squish
      next if href.blank?
      next unless href.include?("/patchnotes/")
      next unless text.downcase.include?("warzone")

      normalize_url(href)
    end.uniq
  end

  def fetch_patch(url)
    doc = Nokogiri::HTML(URI.open(url, HEADERS))
    title = doc.at("h1")&.text&.squish
    content = extract_content(doc)

    return nil if title.blank? || content.blank?

    { title: title, content: content, source_url: url }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "WarzoneScraper: failed to fetch #{url} - #{e.message}"
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
end
