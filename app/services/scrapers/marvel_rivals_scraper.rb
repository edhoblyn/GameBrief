require "open-uri"
require "nokogiri"

class Scrapers::MarvelRivalsScraper
  include Scrapers::PublishedAtExtraction

  BASE_URL = "https://www.marvelrivals.com"
  INDEX_URL = "#{BASE_URL}/gameupdate/"
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }

  def call
    patch_links = fetch_patch_links
    Rails.logger.info "MarvelRivalsScraper: found #{patch_links.size} patches to import"
    patch_links.map { |url| fetch_patch(url) }.compact
  end

  private

  def fetch_patch_links
    doc = Nokogiri::HTML(URI.open(INDEX_URL, HEADERS))
    doc.css("a.list-item").map do |a|
      href = a["href"].to_s
      href.start_with?("http") ? href : BASE_URL + href
    end
  end

  def fetch_patch(url)
    doc = Nokogiri::HTML(URI.open(url, HEADERS))
    title   = doc.at("h1.artTitle")&.text&.strip
    content = doc.at("div.artText")&.text&.strip

    return nil if title.blank? || content.blank?

    { title: title, content: content, source_url: url, published_at: extract_published_at(doc) }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "MarvelRivalsScraper: failed to fetch #{url} — #{e.message}"
    nil
  end
end
