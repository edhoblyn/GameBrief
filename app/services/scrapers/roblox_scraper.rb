require "open-uri"
require "nokogiri"

class Scrapers::RobloxScraper
  INDEX_URL = "https://create.roblox.com/docs/release-notes/release-notes-555"
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
  MAX_NOTES = 26

  def call
    patch_links = fetch_patch_links
    Rails.logger.info "RobloxScraper: found #{patch_links.size} patches to import"
    patch_links.map { |url| fetch_patch(url) }.compact
  end

  private

  def fetch_patch_links
    latest_url = find_latest_release_note_url
    return [] if latest_url.blank?

    urls = []
    current_url = latest_url

    while current_url.present? && urls.size < MAX_NOTES
      urls << current_url
      payload = fetch_payload(current_url)
      previous_path = payload.dig("props", "pageProps", "data", "releaseNoteContents", "prev")
      current_url = normalize_url(previous_path)
    end

    urls.uniq
  end

  def find_latest_release_note_url
    current_url = INDEX_URL
    seen = []

    loop do
      break if current_url.blank? || seen.include?(current_url)

      seen << current_url
      payload = fetch_payload(current_url)
      next_path = payload.dig("props", "pageProps", "data", "releaseNoteContents", "next")
      next_url = normalize_url(next_path)
      break if next_url.blank?

      current_url = next_url
    end

    current_url
  end

  def fetch_patch(url)
    payload = fetch_payload(url)
    data = payload.dig("props", "pageProps", "data", "releaseNoteContents") || {}
    title = data["title"].to_s.squish
    content = build_content(data["content"])

    return nil if title.blank? || content.blank?

    { title: title, content: content, source_url: url }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "RobloxScraper: failed to fetch #{url} - #{e.message}"
    nil
  end

  def fetch_payload(url)
    doc = Nokogiri::HTML(URI.open(url, HEADERS))
    script = doc.at("script#__NEXT_DATA__")
    return {} if script.blank?

    JSON.parse(script.text)
  rescue JSON::ParserError
    {}
  end

  def build_content(entries)
    Array(entries).map do |entry|
      type = entry["ReleaseNotesType"].presence
      status = entry["Status"].presence
      text = entry["ReleaseNotesText"].to_s.squish
      next if text.blank?

      prefix = [type, status].compact.join(" - ")
      prefix.present? ? "#{prefix}: #{text}" : text
    end.compact.join("\n")
  end

  def normalize_url(href)
    return if href.blank?
    return href if href.start_with?("http")
    return URI.join(INDEX_URL, "/docs#{href}").to_s if href.start_with?("/release-notes/")

    URI.join(INDEX_URL, href).to_s
  end
end
