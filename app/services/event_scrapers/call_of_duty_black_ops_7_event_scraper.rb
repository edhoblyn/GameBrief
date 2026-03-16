require "open-uri"
require "nokogiri"

# Scrapes upcoming Call of Duty: Black Ops 7 events with a focus on what casual players care about:
#   - New season launches (new maps, weapons, operators, battle pass)
#   - Season Reloaded mid-season updates (major content drops)
#   - Double XP and limited-time events
#   - Crossover collaborations
#
# Source: callofduty.com/blog/black-ops-7 (server-side rendered, data-date attribute)
module EventScrapers
  class CallOfDutyBlackOps7EventScraper
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }.freeze

    COD_BLOG_URL = "https://www.callofduty.com/blog/black-ops-7".freeze

    # Tag values that signal a casual-player event
    EVENT_TAGS = %w[
      season-one season-two season-three season-four season-five
      season-reloaded events limited-time-modes battle-pass
      news-announcements operators double-xp
    ].freeze

    # Tag values that mean it is NOT a casual event
    EXCLUDE_TAGS = %w[patch-notes esports].freeze

    # Title keywords worth surfacing
    EVENT_TITLE_PATTERN = /
      season\s+\d+            |
      season\s+\d+\s+reloaded |
      reloaded\b              |
      battle\s+pass           |
      double\s+xp             |
      limited[‐\-\s]time      |
      new\s+season            |
      season\s+launch         |
      roadmap                 |
      new\s+map               |
      new\s+mode              |
      event\b                 |
      collab                  |
      collaboration           |
      operator\s+bundle       |
      tracer\s+pack
    /xi.freeze

    # Title keywords that mean it is NOT a casual event
    EXCLUDE_TITLE_PATTERN = /
      patch\s+notes?       |
      anti[‐\-\s]cheat    |
      ricochet             |
      ranked\s+play        |
      playlist\s+update    |
      settings\s+update    |
      performance\s+report |
      bug\s+fix            |
      hot\s+fix
    /xi.freeze

    def call
      events = scrape_blog_events
      Rails.logger.info "EventScrapers::CallOfDutyBlackOps7EventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::CallOfDutyBlackOps7EventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def scrape_blog_events
      doc = Nokogiri::HTML(URI.open(COD_BLOG_URL, HEADERS))

      doc.css(".blog-card-item[data-game]").filter_map do |card|
        game_attr = card["data-game"].to_s
        next unless game_attr.include?("black-ops")

        title_el = card.at_css(".title a")
        next unless title_el

        title = title_el.text.to_s.squish
        next if title.blank? || title.length < 10 || title.length > 200

        date_el  = card.at_css(".news-published")
        date_str = date_el&.[]("data-date").to_s.squish
        pub_date = Date.parse(date_str) rescue nil

        tags = card.css(".tag-list .tag-item").map { |t| t["data-value"].to_s.strip }

        next if tags.any? { |t| EXCLUDE_TAGS.include?(t) }
        next if title.match?(EXCLUDE_TITLE_PATTERN)

        has_event_tag   = tags.any? { |t| EVENT_TAGS.include?(t) }
        has_event_title = title.match?(EVENT_TITLE_PATTERN)
        next unless has_event_tag || has_event_title

        { title: title, description: generate_description(title, tags), start_date: pub_date }
      end.uniq { |e| e[:title] }.first(5)
    rescue StandardError => e
      Rails.logger.warn "CallOfDutyBlackOps7EventScraper#scrape_blog_events: #{e.class}: #{e.message}"
      []
    end

    def generate_description(title, tags)
      case title
      when /season\s+\d+\s+reloaded|reloaded/i
        "Season Reloaded drops the mid-season content wave — new limited-time modes, fresh operator bundles, and bonus Battle Pass content."
      when /season\s+\d+|new\s+season|season\s+launch/i
        "A new Black Ops 7 season launches — bringing new multiplayer maps, weapons, a fresh Battle Pass with exclusive operator skins, and limited-time modes."
      when /roadmap/i
        "The official Black Ops 7 content roadmap reveals what's coming — upcoming seasons, collaborations, and major feature additions on the horizon."
      when /battle\s+pass/i
        "The new Black Ops 7 Battle Pass goes live with 100 tiers of exclusive operator skins, weapon blueprints, and bonus cosmetics."
      when /double\s+xp/i
        "Double XP and Double Weapon XP is active across all Black Ops 7 multiplayer modes for the full event window."
      when /collab|collaboration|tracer\s+pack|operator\s+bundle/i
        "A major crossover collaboration arrives in Black Ops 7 — bringing licensed operator skins, weapon blueprints, and a limited-time themed mode."
      when /limited[‐\-\s]time|event/i
        "A limited-time in-game event runs in Black Ops 7 — featuring unique objectives, exclusive rewards, and a special ruleset."
      else
        "An official Call of Duty: Black Ops 7 announcement — #{title}."
      end
    end
  end
end
