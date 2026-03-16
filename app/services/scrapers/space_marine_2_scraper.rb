require "json"
require "nokogiri"
require "open3"
require "uri"

class Scrapers::SpaceMarine2Scraper
  include Scrapers::PublishedAtExtraction
  include Scrapers::StructuredContentExtraction

  BASE_URL = "https://community.focus-entmt.com".freeze
  INDEX_PATH = "/focus-entertainment/space-marine-2/blogs".freeze
  LOOKBACK_WINDOW = 6.months
  HEADERS = [
    "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
  ].freeze
  TITLE_PATTERNS = [
    /\bpatch notes\b/i,
    /\bhotfix\b/i,
    /\bupdate is live\b/i
  ].freeze

  def call
    entries = fetch_recent_entries
    Rails.logger.info "SpaceMarine2Scraper: found #{entries.size} updates to import"

    entries
      .filter_map { |entry| fetch_patch(entry) }
      .uniq { |entry| entry[:source_url] }
      .sort_by { |entry| -(entry[:published_at]&.to_i || 0) }
  end

  private

  def fetch_recent_entries
    initial_doc = fetch_document(index_url(1))
    max_pages = extract_max_pages(initial_doc)
    entries = []

    (1..max_pages).each do |page|
      doc = page == 1 ? initial_doc : fetch_document(index_url(page))
      page_entries = extract_page_entries(doc)
      break if page_entries.empty?

      entries.concat(page_entries)

      oldest_relevant_entry = page_entries.reverse.find do |entry|
        entry[:relative_published_at].present?
      end

      break if oldest_relevant_entry.present? && oldest_relevant_entry[:relative_published_at] < lookback_cutoff
    end

    entries.uniq { |entry| entry[:source_url] }
  end

  def extract_page_entries(doc)
    doc.css(".devblog-showroom-item").filter_map do |card|
      title = card.at_css(".title-article")&.text&.squish
      next if title.blank?
      next unless relevant_title?(title)

      href = card.at_css(".devblog-showroom-item-more-link[href]")&.[]("href")
      source_url = normalize_url(href)
      next if source_url.blank?

      {
        title: title,
        source_url: source_url,
        relative_published_at: relative_published_at_for(card.at_css(".since-when")&.text)
      }
    end
  end

  def fetch_patch(entry)
    doc = fetch_document(entry[:source_url])
    blogpost = extract_blogpost_payload(doc)
    title = blogpost["Title"].to_s.squish.presence || entry[:title]
    raw_content = blogpost["Content"].to_s
    content = extract_content(raw_content, title: title)
    published_at = parse_published_at(blogpost["DatePublication"]) || extract_published_at(doc)
    source_url = canonical_url_for(doc, blogpost) || entry[:source_url]

    return nil if title.blank? || content.blank?
    return nil unless relevant_title?(title)
    return nil if published_at.present? && published_at < lookback_cutoff

    {
      title: title,
      content: content,
      source_url: source_url,
      published_at: published_at
    }
  rescue JSON::ParserError, KeyError => e
    Rails.logger.warn "SpaceMarine2Scraper: failed to parse #{entry[:source_url]} - #{e.class}: #{e.message}"
    nil
  end

  def fetch_document(url)
    stdout, stderr, status = Open3.capture3(*curl_command(url))
    raise "curl failed for #{url}: #{stderr.presence || stdout.presence || status.exitstatus}" unless status.success?

    Nokogiri::HTML(stdout)
  end

  def curl_command(url)
    command = ["curl", "-sS", "-L", "--fail"]
    HEADERS.each do |header|
      command << "-H"
      command << header
    end
    command << url
    command
  end

  def extract_blogpost_payload(doc)
    raw_state = doc.at_css("#ng-state")&.text.to_s
    raise KeyError, "missing ng-state payload" if raw_state.blank?

    payload = JSON.parse(raw_state)
    payload.fetch("blogpost")
  end

  def extract_content(raw_content, title:)
    fragment = Nokogiri::HTML::DocumentFragment.parse(raw_content.to_s)
    extract_text_blocks(fragment, title: title) || fragment.text.to_s.squish
  end

  def canonical_url_for(doc, blogpost)
    doc.at("meta[property='og:url']")&.[]("content").presence ||
      normalize_url(blogpost["RootUrl"])
  end

  def index_url(page)
    return "#{BASE_URL}#{INDEX_PATH}" if page.to_i <= 1

    "#{BASE_URL}#{INDEX_PATH}?page=#{page}"
  end

  def extract_max_pages(doc)
    pages = doc.css(".pager-buttons a[href*='?page=']").filter_map do |link|
      href = link["href"].to_s
      next unless href.include?("?page=")

      href[/[?&]page=(\d+)/, 1]&.to_i
    end

    pages.max || 1
  end

  def relevant_title?(title)
    TITLE_PATTERNS.any? { |pattern| title.match?(pattern) }
  end

  def normalize_url(value)
    return if value.blank?
    return value if value.start_with?("http")

    URI.join(BASE_URL, value).to_s
  end

  def relative_published_at_for(value)
    text = value.to_s.squish.downcase
    return if text.blank?

    if (match = text.match(/\A(\d+)\s+(hour|day|week|month|year)s?\s+ago\z/))
      amount = match[1].to_i
      unit = match[2]
      return amount.public_send(unit).ago
    end

    return 1.day.ago if text == "yesterday"
    return Time.current if text == "today"
  end

  def lookback_cutoff
    @lookback_cutoff ||= LOOKBACK_WINDOW.ago.beginning_of_day
  end
end
