require "cgi"
require "json"
require "nokogiri"
require "open-uri"

class Scrapers::Dota2Scraper
  INDEX_URL = "https://store.steampowered.com/news/app/570?updates=true"
  DETAIL_URL_TEMPLATE = "https://store.steampowered.com/news/app/570/view/%<id>s"
  LOOKBACK_WINDOW = 6.months
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
  TITLE_PATTERNS = [
    /\ADota 2 Update - \d{1,2}\/\d{1,2}\/\d{4}\z/i,
    /\A7\.\d+[a-z]?\s+Gameplay Patch\z/i,
    /\AIntroducing .+ and Patch 7\.\d+[a-z]?\z/i
  ].freeze

  def call
    events = fetch_recent_events
    Rails.logger.info "Dota2Scraper: found #{events.size} updates to import"

    events.filter_map do |event|
      build_patch(event)
    end
  end

  private

  def fetch_recent_events
    doc = fetch_document(INDEX_URL)
    initial_events = extract_json_attribute(doc, "data-initialevents")

    Array(initial_events["events"]).filter_map do |event|
      title = event.dig("announcement_body", "headline").to_s.squish
      published_at = extract_published_at(event)

      next if title.blank?
      next unless relevant_title?(title)
      next if published_at.present? && published_at < lookback_cutoff

      event
    end
  end

  def build_patch(event)
    title = event.dig("announcement_body", "headline").to_s.squish
    content = format_steam_markup(event.dig("announcement_body", "body").to_s)
    source_url = format(DETAIL_URL_TEMPLATE, id: event["gid"])
    published_at = extract_published_at(event)

    return nil if title.blank? || content.blank?

    {
      title: title,
      content: content,
      source_url: source_url,
      published_at: published_at
    }
  end

  def fetch_document(url)
    Nokogiri::HTML(URI.open(url, HEADERS))
  end

  def extract_json_attribute(doc, attribute_name)
    config_node = doc.at("#application_config")
    raise "Dota 2 scraper could not find #{attribute_name}" if config_node.blank?

    raw_value = config_node[attribute_name].presence || config_node[attribute_name.downcase].presence
    raise "Dota 2 scraper could not find #{attribute_name}" if raw_value.blank?

    JSON.parse(raw_value)
  end

  def extract_published_at(event)
    timestamp = event.dig("announcement_body", "posttime").to_i
    timestamp = event["rtime32_start_time"].to_i if timestamp.zero?
    return if timestamp.zero?

    Time.zone.at(timestamp)
  end

  def relevant_title?(title)
    TITLE_PATTERNS.any? { |pattern| title.match?(pattern) }
  end

  def format_steam_markup(raw_content)
    return "" if raw_content.blank?

    content = CGI.unescapeHTML(raw_content.to_s)
    content.gsub!(/\r\n?/, "\n")
    content.gsub!(%r{\[previewyoutube=.*?\].*?\[/previewyoutube\]}im, "")
    content.gsub!(%r{\[img(?: [^\]]*)?\].*?\[/img\]}im, "")
    content.gsub!(/\{STEAM_CLAN_IMAGE\}/, "")
    content.gsub!(/\[list\]/i, "")
    content.gsub!(/\[\/list\]/i, "")
    content.gsub!(/\[\*\]\s*/i, "- ")
    content.gsub!(/\[\/\*\]/i, "\n")
    content.gsub!(/\[p\]/i, "")
    content.gsub!(/\[\/p\]/i, "\n")
    content.gsub!(/\[\/?(?:h1|h2|h3|h4|b|i|u|quote)\]/i, "")
    content.gsub!(%r{\[url="?([^\]"]+)"?\](.*?)\[/url\]}im, "\\2 (\\1)")
    content.gsub!(/\n{3,}/, "\n\n")

    content.lines.map(&:rstrip).join("\n").strip
  end

  def lookback_cutoff
    @lookback_cutoff ||= LOOKBACK_WINDOW.ago.beginning_of_day
  end
end
