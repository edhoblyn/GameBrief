require "json"
require "nokogiri"
require "open-uri"

class Scrapers::PubgBattlegroundsScraper
  INDEX_URL_TEMPLATE = "https://pubg.com/en/news?category=patch_notes&page=%<page>d"
  DETAIL_URL_TEMPLATE = "https://pubg.com/en/news/%<id>s"
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
  LOOKBACK_WINDOW = 6.months
  TITLE_PATTERN = /\APatch Notes - Update \d+\.\d+\z/i
  INDEX_ENTRY_PATTERN = /
    postId:(?<post_id>\d+),
    .*?displayStartTime:"(?<published_at>[^"]+)",
    .*?title:"(?<title>(?:\\.|[^"])*)"
  /mx
  MAX_PAGES = 20

  def call
    patch_entries = fetch_patch_entries
    Rails.logger.info "PubgBattlegroundsScraper: found #{patch_entries.size} patch notes to import"
    patch_entries.filter_map { |entry| fetch_patch(entry) }
  end

  private

  def fetch_patch_entries
    page = 1
    entries = []

    loop do
      page_entries = parse_index_entries(fetch_html(format(INDEX_URL_TEMPLATE, page: page)))
      break if page_entries.empty?

      entries.concat(page_entries.select { |entry| entry[:published_at] >= lookback_cutoff })
      break if page_entries.last[:published_at] < lookback_cutoff

      page += 1
      break if page > MAX_PAGES
    end

    entries.uniq { |entry| entry[:source_url] }
  end

  def parse_index_entries(html)
    html.to_s.scan(INDEX_ENTRY_PATTERN).filter_map do |post_id, published_at_raw, raw_title|
      title = decode_js_string(raw_title).squish
      next unless title.match?(TITLE_PATTERN)

      published_at = Time.zone.parse(published_at_raw)
      next if published_at.nil?

      {
        title: title,
        source_url: format(DETAIL_URL_TEMPLATE, id: post_id),
        published_at: published_at
      }
    rescue JSON::ParserError, ArgumentError
      nil
    end
  end

  def fetch_patch(entry)
    doc = fetch_document(entry[:source_url])
    content = extract_content(doc)
    source_url = doc.at("link[rel='canonical']")&.[]("href").presence || entry[:source_url]

    return nil if content.blank?

    {
      title: entry[:title],
      content: content,
      source_url: source_url,
      published_at: entry[:published_at]
    }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "PubgBattlegroundsScraper: failed to fetch #{entry[:source_url]} - #{e.message}"
    nil
  end

  def fetch_document(url)
    Nokogiri::HTML(URI.open(url, HEADERS))
  end

  def fetch_html(url)
    URI.open(url, HEADERS).read
  end

  def extract_content(doc)
    container = doc.at(".content-template__inner.fr-view > div") || doc.at(".content-template__inner.fr-view")
    return "" if container.blank?

    cleaned = container.dup
    cleaned.css("img, iframe, hr, .fr-video").remove

    blocks = cleaned.children.each_with_object([]) do |child, items|
      next unless child.element?

      case child.name
      when "h1", "h2", "h3", "h4", "h5", "h6", "p"
        append_block(items, child.text.to_s.squish)
      when "ul", "ol"
        child.css("> li").each do |item|
          append_block(items, "- #{item.text.to_s.squish}")
        end
      end
    end

    blocks.join("\n")
  end

  def append_block(items, text)
    return if text.blank?
    return if items.last == text

    items << text
  end

  def decode_js_string(raw_value)
    JSON.parse(%("#{raw_value}"))
  end

  def lookback_cutoff
    @lookback_cutoff ||= LOOKBACK_WINDOW.ago.beginning_of_day
  end
end
