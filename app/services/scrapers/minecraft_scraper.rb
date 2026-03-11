require "open-uri"
require "nokogiri"

class Scrapers::MinecraftScraper
  INDEX_URL = "https://feedback.minecraft.net/hc/en-us/sections/360001186971-Release-Changelogs"
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
  TITLE_PATTERN = /(minecraft: java edition|minecraft: bedrock edition|minecraft - \d|changelog|hotfix)/i

  def call
    patch_links = fetch_patch_links
    Rails.logger.info "MinecraftScraper: found #{patch_links.size} patches to import"
    patch_links.map { |url| fetch_patch(url) }.compact
  end

  private

  def fetch_patch_links
    doc = Nokogiri::HTML(URI.open(INDEX_URL, HEADERS))

    doc.css("a[href]").filter_map do |link|
      href = link["href"].to_s.strip
      text = link.text.to_s.squish
      next if href.blank? || text.blank?
      next unless href.include?("/hc/en-us/articles/")
      next unless text.match?(TITLE_PATTERN)

      normalize_url(href)
    end.uniq
  end

  def fetch_patch(url)
    doc = Nokogiri::HTML(URI.open(url, HEADERS))
    title = doc.at("h1")&.text&.squish
    content = extract_content(doc)

    return nil if title.blank? || content.blank?
    return nil unless title.match?(TITLE_PATTERN)

    { title: title, content: content, source_url: url }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "MinecraftScraper: failed to fetch #{url} - #{e.message}"
    nil
  end

  def extract_content(doc)
    selectors = [
      "article",
      "main",
      ".article-body",
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
