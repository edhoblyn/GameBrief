require "json"
require "nokogiri"
require "open3"
require "uri"

class Scrapers::GenshinImpactScraper
  include Scrapers::StructuredContentExtraction

  LIST_URL = "https://bbs-api-os.hoyolab.com/community/post/wapi/getNewsList"
  DETAIL_URL = "https://bbs-api-os.hoyolab.com/community/post/wapi/getPostFull"
  ARTICLE_URL_TEMPLATE = "https://www.hoyolab.com/article/%<post_id>s"
  GAME_ID = 2
  NEWS_TYPE = 1
  PAGE_SIZE = 80
  LOOKBACK_WINDOW = 6.months
  OFFICIAL_USER_ID = "1015537"
  CURL_HEADERS = [
    "Origin: https://www.hoyolab.com",
    "X-Rpc-Language: en-us",
    "Accept: application/json",
    "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
  ].freeze
  TITLE_PATTERNS = [
    /\AVersion .+ Version Details - What's New/i,
    /Update Details\z/i,
    /\AVersion .+ Update Maintenance Preview\z/i,
    /\AIssue Fix Details\z/i,
    /\AIn-Game Issue Summary\z/i,
    /Maintenance Details\z/i,
    /\AFixes to In-Game .+\z/i,
    /\ASolutions for Game Launch Issues .+\z/i,
    /\AGenshin Impact: Details and Temporary Solution .+\z/i
  ].freeze

  def call
    entries = fetch_recent_entries
    Rails.logger.info "GenshinImpactScraper: found #{entries.size} updates to import"

    entries.filter_map do |entry|
      fetch_patch(entry)
    end
  end

  private

  def fetch_recent_entries
    payload = request_json(LIST_URL, gids: GAME_ID, page_size: PAGE_SIZE, type: NEWS_TYPE)

    Array(payload.dig("data", "list")).filter_map do |item|
      post = item.fetch("post", {})
      user = item.fetch("user", {})
      title = post["subject"].to_s.squish
      published_at = timestamp_to_time(post["created_at"])

      next if title.blank?
      next unless official_post?(user)
      next unless relevant_title?(title)
      next if published_at.present? && published_at < lookback_cutoff

      {
        post_id: post["post_id"].to_s,
        title: title,
        published_at: published_at
      }
    end
  end

  def fetch_patch(entry)
    payload = request_json(DETAIL_URL, gids: GAME_ID, post_id: entry[:post_id])
    post_wrapper = payload.dig("data", "post") || {}
    post = post_wrapper.fetch("post", {})
    title = post["subject"].to_s.squish.presence || entry[:title]
    content = extract_content(post, title: title)
    published_at = timestamp_to_time(post["created_at"]) || entry[:published_at]

    return nil if title.blank? || content.blank?
    return nil unless relevant_title?(title)
    return nil if published_at.present? && published_at < lookback_cutoff

    {
      title: title,
      content: content,
      source_url: format(ARTICLE_URL_TEMPLATE, post_id: entry[:post_id]),
      published_at: published_at
    }
  rescue StandardError => e
    Rails.logger.warn "GenshinImpactScraper: failed to fetch #{entry[:post_id]} - #{e.class}: #{e.message}"
    nil
  end

  def request_json(base_url, params)
    url = "#{base_url}?#{URI.encode_www_form(params)}"
    command = ["curl", "-sS", "-L", "--fail"]
    CURL_HEADERS.each do |header|
      command << "-H"
      command << header
    end
    command << url

    stdout, stderr, status = Open3.capture3(*command)
    raise "curl failed for #{url}: #{stderr.presence || stdout.presence || status.exitstatus}" unless status.success?

    payload = JSON.parse(stdout)
    retcode = payload["retcode"]
    raise "HoYoLAB API returned retcode #{retcode}: #{payload["message"]}" unless retcode == 0

    payload
  end

  def extract_content(post, title:)
    raw_content = post["content"].to_s

    if structured_content_fallback?(raw_content)
      structured_text = parse_structured_content(post["structured_content"].to_s)
      return structured_text if structured_text.present?
    end

    fragment = Nokogiri::HTML::DocumentFragment.parse(raw_content)
    extract_text_blocks(fragment, title: title) || fragment.text.to_s.squish
  end

  def parse_structured_content(raw_content)
    nodes = JSON.parse(raw_content)

    blocks = nodes.flat_map do |node|
      insert = node["insert"]

      case insert
      when String
        insert.to_s.split(/\r?\n/).map(&:squish).reject(&:blank?)
      else
        []
      end
    end

    blocks.uniq.join("\n")
  rescue JSON::ParserError
    nil
  end

  def structured_content_fallback?(raw_content)
    raw_content.blank? || raw_content.match?(/\A[a-z]{2}-[a-z]{2}\z/i)
  end

  def official_post?(user)
    user["uid"].to_s == OFFICIAL_USER_ID
  end

  def relevant_title?(title)
    TITLE_PATTERNS.any? { |pattern| title.match?(pattern) }
  end

  def timestamp_to_time(value)
    timestamp = value.to_i
    return if timestamp.zero?

    Time.zone.at(timestamp)
  end

  def lookback_cutoff
    @lookback_cutoff ||= LOOKBACK_WINDOW.ago.beginning_of_day
  end
end
