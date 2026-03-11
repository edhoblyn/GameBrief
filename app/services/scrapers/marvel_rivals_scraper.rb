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
    published_at = extract_detail_date(doc, title) || extract_published_at(doc)

    return nil if title.blank? || content.blank?

    { title: title, content: content, source_url: url, published_at: published_at }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "MarvelRivalsScraper: failed to fetch #{url} — #{e.message}"
    nil
  end

  def extract_detail_date(doc, title)
    published_at = parse_published_at(doc.at("p.date")&.text)
    normalize_detail_date(published_at, title)
  end

  def normalize_detail_date(published_at, title)
    return published_at if published_at.blank? || title.blank?

    version_date = extract_version_date(title)
    return published_at if version_date.blank?

    if published_at.year == version_date.year &&
       published_at.month > version_date.month &&
       published_at > 6.months.from_now
      published_at.change(year: published_at.year - 1)
    else
      published_at
    end
  end

  def extract_version_date(title)
    match = title.match(/Version\s+(\d{4})(\d{2})(\d{2})/i)
    return if match.nil?

    Time.zone.local(match[1].to_i, match[2].to_i, match[3].to_i)
  rescue ArgumentError
    nil
  end
end
