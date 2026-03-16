require "open-uri"
require "nokogiri"

# Scrapes Arc Raiders events from arcraiders.com/news.
#
# The patch scraper targets cards tagged "Patch Notes".
# This scraper targets the complementary event-type tags:
#   Updates, Trials, Community
#
# Returns an array of hashes:
#   { title: String, description: String, start_date: Date or nil }
module EventScrapers
  class ArcRaidersEventScraper
    include Scrapers::PublishedAtExtraction

    BASE_URL  = "https://arcraiders.com".freeze
    INDEX_URL = "#{BASE_URL}/news".freeze
    HEADERS   = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }.freeze

    # The "Patch Notes" tag is the only reliable tag on arcraiders.com.
    # Event articles typically have no tags — so we filter by title pattern instead.
    PATCH_NOTES_TAG = "Patch Notes".freeze

    # Title must match at least one of these to be treated as an event
    EVENT_TITLE_PATTERNS = [
      /\b(headwinds|shrouded sky|flashpoint|riven tides)\b/i,  # Named season updates
      /trials season \d+/i,                                     # Competitive Trials seasons
      /community competition/i,                                  # Community challenges
      /\Awelcome to the server slam\z/i,                        # Server Slam open test (launch post only)
    ].freeze

    # Skip articles that are newsletters, wrap-ups, or reminders for an event
    # rather than the event launch itself
    EXCLUDE_TITLE_PATTERNS = [
      /thank you.*server slam|server slam.*thank you/i,
      /news from the rust belt/i,
      /play arc raiders this weekend/i,
    ].freeze

    # Only import articles from the last 6 months to keep events relevant
    RECENT_WINDOW = 6.months.freeze

    # Named update descriptions for the 2026 Escalation roadmap
    UPDATE_DESCRIPTIONS = {
      /headwinds/i      => "The Headwinds update arrives with a new Level 40+ matchmaking option, the Bird City map condition, and fresh Raider quests and Feats.",
      /shrouded sky/i   => "Shrouded Sky brings a Hurricane map condition with low visibility and flying debris, two new ARC enemies (Firefly and Comet), and a new Expedition window.",
      /flashpoint/i     => "Flashpoint introduces a new lightning weather map condition, a tougher ARC enemy variant, a new Player Project, and a Scrappy companion rework.",
      /riven tides/i    => "Riven Tides is the largest Escalation update — a brand-new map joins the world alongside a new large ARC threat and a fresh Expedition window.",
      /trials/i         => "A new Trials season begins with weekly rotating tasks and unique cosmetic rewards for all Raiders who hit their target rank by season end.",
      /storm stories/i  => "A community competition inviting Raiders to share their best storm-run moments for recognition and in-game rewards.",
      /server slam/i    => "A limited-time open test event — the Server Slam opens the game to all players for a weekend of extraction mayhem.",
    }.freeze

    def call
      cards = fetch_event_cards
      Rails.logger.info "EventScrapers::ArcRaidersEventScraper: found #{cards.size} event cards"
      cards
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::ArcRaidersEventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def fetch_event_cards
      doc = Nokogiri::HTML(URI.open(INDEX_URL, HEADERS))

      doc.css("a[class*='news-article-card_container']").filter_map do |card|
        title = card.at_css("[class*='news-article-card_title']")&.text&.squish
        next if title.blank?
        next if patch_card?(card)
        next unless event_card?(title)
        next if excluded_title?(title)

        date_text  = card.at_css("[class*='news-article-card_date']")&.text
        start_date = parse_date(date_text)
        next if start_date.present? && start_date < RECENT_WINDOW.ago.beginning_of_day

        description = generate_description(title)
        { title: title, description: description, start_date: start_date }
      end.uniq { |e| e[:title] }
    end

    # Returns true if the card is tagged "Patch Notes" (handled by the patch scraper)
    def patch_card?(card)
      tags = card.css(
        "[class*='news-article-card_tags'] [data-text]," \
        "[class*='news-article-card_tags'] a," \
        "[class*='news-article-card_tags'] div"
      ).map { |n| n.text.squish }.reject(&:blank?)
      tags.include?(PATCH_NOTES_TAG)
    end

    # Returns true if the title matches a known event pattern
    def event_card?(title)
      EVENT_TITLE_PATTERNS.any? { |pattern| title.match?(pattern) }
    end

    def excluded_title?(title)
      EXCLUDE_TITLE_PATTERNS.any? { |pattern| title.match?(pattern) }
    end

    def generate_description(title)
      UPDATE_DESCRIPTIONS.each do |pattern, desc|
        return desc if title.match?(pattern)
      end
      "An official Arc Raiders content update or community event — #{title}."
    end

    def parse_date(date_text)
      parse_published_at(date_text)
    rescue StandardError
      nil
    end
  end
end
