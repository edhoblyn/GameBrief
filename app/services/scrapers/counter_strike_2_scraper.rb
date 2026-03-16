require "cgi"
require "json"
require "nokogiri"
require "open-uri"

class Scrapers::CounterStrike2Scraper
  INDEX_URL = "https://store.steampowered.com/news/app/730?updates=true"
  DETAIL_URL_TEMPLATE = "https://store.steampowered.com/news/app/730/view/%<id>s"
  LOOKBACK_WINDOW = 6.months
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
  UPDATE_EVENT_TYPE = 12
  TITLE_PATTERN = /\Acounter-strike 2 update\z/i

  def call
    event_entries = fetch_event_entries
    Rails.logger.info "CounterStrike2Scraper: found #{event_entries.size} updates to import"
    event_entries.filter_map { |entry| fetch_patch(entry) }
  end

  private

  def fetch_event_entries
    doc = fetch_document(INDEX_URL)
    initial_events = extract_json_attribute(doc, "data-initialEvents")
    documents = initial_events.fetch("documents", [])

    documents.filter_map do |document|
      next unless document["event_type"].to_i == UPDATE_EVENT_TYPE

      published_at = Time.zone.at(document["start_time"].to_i)
      next if published_at < lookback_cutoff

      {
        source_url: format(DETAIL_URL_TEMPLATE, id: document["unique_id"]),
        published_at: published_at
      }
    end.uniq { |entry| entry[:source_url] }
  end

  def fetch_patch(entry)
    doc = fetch_document(entry[:source_url])
    event_payload = extract_event_payload(doc)
    title = event_payload.dig("announcement_body", "headline").to_s.squish
    content = format_steam_markup(event_payload.dig("announcement_body", "body").to_s)
    published_at = extract_published_at(doc, event_payload) || entry[:published_at]
    source_url = doc.at("link[rel='canonical']")&.[]("href").presence || entry[:source_url]

    return nil if title.blank? || content.blank?
    return nil unless title.match?(TITLE_PATTERN)
    return nil if published_at.present? && published_at < lookback_cutoff

    {
      title: title,
      content: content,
      source_url: source_url,
      published_at: published_at
    }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "CounterStrike2Scraper: failed to fetch #{entry[:source_url]} - #{e.message}"
    nil
  end

  def fetch_document(url)
    Nokogiri::HTML(URI.open(url, HEADERS))
  end

  def extract_json_attribute(doc, attribute_name)
    config_node = doc.at("#application_config")
    raise "Counter-Strike 2 scraper could not find #{attribute_name}" if config_node.blank?

    raw_value = config_node[attribute_name].presence || config_node[attribute_name.downcase].presence
    raise "Counter-Strike 2 scraper could not find #{attribute_name}" if raw_value.blank?

    JSON.parse(raw_value)
  end

  def extract_event_payload(doc)
    events = extract_json_attribute(doc, "data-partnereventstore")
    events.find { |event| event["announcement_body"].present? } || {}
  end

  def extract_published_at(doc, event_payload)
    meta_value = doc.at("meta[property='article:published_time']")&.[]("content")
    return Time.zone.parse(meta_value) if meta_value.present?

    timestamp = event_payload.dig("announcement_body", "posttime").to_i
    return if timestamp.zero?

    Time.zone.at(timestamp)
  rescue ArgumentError
    nil
  end

  def format_steam_markup(raw_content)
    return "" if raw_content.blank?

    content = CGI.unescapeHTML(raw_content.to_s)
    content.gsub!(/\r\n?/, "\n")
    content.gsub!(/\[list\]/i, "")
    content.gsub!(/\[\/list\]/i, "")
    content.gsub!(/\[\*\]\s*/i, "- ")
    content.gsub!(%r{\[url=([^\]]+)\](.*?)\[/url\]}im, "\\2 (\\1)")
    content.gsub!(%r{\[/?(?:i|b|u|h1|h2|h3|quote)\]}i, "")
    content.gsub!(/\[img\].*?\[\/img\]/im, "")
    content.gsub!(/\[carousel\].*?\[\/carousel\]/im, "")
    content.gsub!(/\n{3,}/, "\n\n")

    content.lines.map(&:rstrip).join("\n").strip
  end

  def lookback_cutoff
    @lookback_cutoff ||= LOOKBACK_WINDOW.ago.beginning_of_day
  end
end
