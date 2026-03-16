require "open-uri"
require "nokogiri"

# Scrapes upcoming Battlefield 6 events with a focus on what casual players care about:
#   - New season launches (new maps, weapons, specialists, battle pass)
#   - Limited-time modes and Battlefield Portal events
#   - Roadmap articles announcing upcoming content
#   - Major collaboration or crossover events
#
# Source: EA BF6 news — https://www.ea.com/games/battlefield/battlefield-6/news
module EventScrapers
  class Battlefield6EventScraper
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }.freeze

    EA_NEWS_URL = "https://www.ea.com/games/battlefield/battlefield-6/news".freeze

    # EA link text format: "News ArticleMarch 3, 2026Title Here"
    EA_TYPE_PREFIX  = /\A(news\s+article|game\s+updates?|guides?)/i.freeze
    EA_DATE_PATTERN = /([A-Z][a-z]+ \d{1,2}, \d{4})/

    # Article titles worth surfacing to casual players
    EVENT_PATTERN = /
      season\s+\d+      |   # "Season 3", "Season 4"
      new\s+season      |
      season\s+launch   |
      new\s+map         |
      new\s+mode        |
      roadmap           |
      battle\s+pass     |
      portal            |   # Battlefield Portal
      limited[‐\-\s]time |
      collaboration     |
      collab            |
      anniversary       |
      event\b           |
      phase\s+\d+       |
      hunter            |   # Season 2 Phase 3 Hunter-Prey
      update\s+preview  |
      seasonal\s+content
    /xi.freeze

    # Exclude non-event content
    EXCLUDE_PATTERN = /
      patch\s+notes?      |
      game\s+update       |
      designer.s\s+notes  |
      anti[\s\-]cheat     |
      creator\s+program   |
      community\s+update  |
      accessibility       |
      performance\s+report|
      nvidia              |
      technical\s+test    |
      guide\b             |
      tips\b
    /xi.freeze

    def call
      events = scrape_news_events
      Rails.logger.info "EventScrapers::Battlefield6EventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::Battlefield6EventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def scrape_news_events
      doc = Nokogiri::HTML(URI.open(EA_NEWS_URL, HEADERS))

      doc.css("a[href]").filter_map do |link|
        href = link["href"].to_s.strip
        text = link.text.to_s.squish

        next if href.blank? || text.blank?
        next unless href.include?("/battlefield/battlefield-6/")
        next if text.length < 10 || text.length > 200

        # Skip "Game Updates" and "Guides" category articles (those are patch notes / tips)
        next if text.match?(/\A(game\s+updates?|guides?)\s+[A-Z]/i)

        pub_date = text.match(EA_DATE_PATTERN) && Date.parse($1) rescue nil

        clean = text.gsub(EA_TYPE_PREFIX, "")
                    .gsub(EA_DATE_PATTERN, "")
                    .squish
        next if clean.blank? || clean.length < 10

        next unless clean.match?(EVENT_PATTERN)
        next if clean.match?(EXCLUDE_PATTERN)

        { title: clean, description: generate_description(clean), start_date: pub_date }
      end.uniq { |e| e[:title] }.first(5)
    rescue StandardError => e
      Rails.logger.warn "Battlefield6EventScraper#scrape_news_events: #{e.class}: #{e.message}"
      []
    end

    def generate_description(title)
      case title
      when /season\s+\d+|new\s+season|season\s+launch/i
        "A new Battlefield 6 season arrives — bringing new maps, weapons, specialists, and a fresh Battle Pass with exclusive cosmetics."
      when /phase\s+\d+|hunter/i
        "A new seasonal phase drops fresh in-game content, including limited-time modes, new cosmetics, and gameplay events."
      when /roadmap/i
        "EA reveals the upcoming content roadmap for Battlefield 6 — covering new seasons, maps, modes, and major updates on the horizon."
      when /portal/i
        "Battlefield Portal returns with classic maps, weapons, and game modes from Battlefield's history — available for a limited time."
      when /battle\s+pass/i
        "The new Battlefield 6 Battle Pass launches with exclusive operator skins, weapon blueprints, and XP boosts across 100 tiers."
      when /collab|collaboration/i
        "A major crossover collaboration brings exclusive branded cosmetics and limited-time content to Battlefield 6."
      when /anniversary/i
        "Battlefield 6's anniversary celebration — featuring free rewards, returning modes, and community highlights."
      else
        "An official Battlefield 6 in-game event — #{title}."
      end
    end
  end
end
