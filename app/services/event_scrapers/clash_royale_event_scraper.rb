require "open-uri"
require "nokogiri"

# Scrapes upcoming Clash Royale events with a focus on what casual players care about:
#   - New season launches (new cards, season pass, progression reset)
#   - Mid-season updates with new content
#   - Global Tournaments
#   - Anniversary and special events
#
# Source: supercell.com/en/games/clashroyale/blog/
module EventScrapers
  class ClashRoyaleEventScraper
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }.freeze

    BLOG_URL = "https://supercell.com/en/games/clashroyale/blog/".freeze

    EVENT_PATTERN = /
      new\s+season        |
      season\s+\d+        |
      season:             |
      season\s+update     |
      mid[\s\-]season     |
      anniversary         |
      global\s+tournament |
      new\s+card          |
      new\s+cards         |
      collab              |
      collaboration       |
      limited[‐\-\s]time  |
      special\s+event     |
      event\b             |
      merge\s+tactics     |
      pass\s+royale       |
      season\s+pass
    /xi.freeze

    EXCLUDE_PATTERN = /
      balance\s+(update|change) |
      balance\s+changes         |
      patch                     |
      exploit                   |
      bug\s+fix                 |
      maintenance               |
      creator\s+spotlight       |
      community\s+content       |
      terms\s+of\s+service      |
      privacy\s+policy          |
      dev\s+update              |
      behind\s+the\s+scenes
    /xi.freeze

    def call
      events = scrape_blog
      Rails.logger.info "EventScrapers::ClashRoyaleEventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::ClashRoyaleEventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def scrape_blog
      doc = Nokogiri::HTML(URI.open(BLOG_URL, HEADERS))

      doc.css("p[data-test-id='publish-date-text']").filter_map do |date_el|
        title_el = date_el.parent.at_css("[class*='title']")
        next unless title_el

        title = title_el.text.to_s.squish
        next if title.blank? || title.length < 8

        date_str = date_el.text.to_s.squish
        pub_date = Date.parse(date_str) rescue nil

        next unless title.match?(EVENT_PATTERN)
        next if title.match?(EXCLUDE_PATTERN)

        { title: title, description: generate_description(title), start_date: pub_date }
      end.uniq { |e| e[:title] }.first(5)
    rescue StandardError => e
      Rails.logger.warn "ClashRoyaleEventScraper#scrape_blog: #{e.class}: #{e.message}"
      []
    end

    def generate_description(title)
      case title
      when /new\s+season|season\s+\d+|season:|pass\s+royale|season\s+pass/i
        "A new Clash Royale season begins — new cards arrive, the season Pass Royale resets with fresh cosmetics, and the season shop refreshes with exclusive emotes and tower skins."
      when /mid[\s\-]season|merge\s+tactics/i
        "The mid-season update lands with new card unlocks, progression events, and balance tweaks — a great time to log in and grab seasonal rewards."
      when /global\s+tournament/i
        "Global Tournaments are open — enter a limited-use deck and compete for trophies, Gold, and exclusive in-game rewards on the global ladder."
      when /anniversary/i
        "Clash Royale's anniversary celebration — featuring free rewards, returning limited-time modes, and community milestones."
      when /collab|collaboration/i
        "A major crossover collaboration arrives in Clash Royale — bringing branded card backs, tower skins, and a limited-time themed event."
      when /new\s+cards?/i
        "New cards arrive in Clash Royale — adding fresh strategic options to your deck with unique abilities and new upgrade paths."
      else
        "An official Clash Royale in-game event — #{title}."
      end
    end
  end
end
