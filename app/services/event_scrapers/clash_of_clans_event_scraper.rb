require "open-uri"
require "nokogiri"

# Scrapes upcoming Clash of Clans events with a focus on what casual players care about:
#   - Seasonal Gold Pass (monthly themed season)
#   - Clan Games
#   - Clan Rush and limited-time events
#   - Town Hall / Builder Base major content updates
#   - Anniversary and collaboration events
#
# Source: supercell.com/en/games/clashofclans/blog/
module EventScrapers
  class ClashOfClansEventScraper
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }.freeze

    BLOG_URL = "https://supercell.com/en/games/clashofclans/blog/".freeze

    # Titles worth surfacing to casual players
    EVENT_PATTERN = /
      clan\s+rush        |
      clan\s+games       |
      season\s+challenge |
      gold\s+pass        |
      town\s+hall\s+\d+  |
      builder\s+base     |
      new\s+troop        |
      new\s+hero         |
      new\s+season       |
      season\s+begins    |
      anniversary        |
      collab             |
      collaboration      |
      limited[‐\-\s]time |
      special\s+event    |
      event\b            |
      update\b           |
      super\s+troop      |
      cwl\b              |
      war\s+league
    /xi.freeze

    # Titles that are NOT casual events
    EXCLUDE_PATTERN = /
      balance\s+(update|change) |
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
      Rails.logger.info "EventScrapers::ClashOfClansEventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::ClashOfClansEventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def scrape_blog
      doc = Nokogiri::HTML(URI.open(BLOG_URL, HEADERS))

      doc.css("p[data-test-id='publish-date-text']").filter_map do |date_el|
        title_el = date_el.parent.at_css("[class*='title']")
        next unless title_el

        title    = title_el.text.to_s.squish
        next if title.blank? || title.length < 8

        date_str = date_el.text.to_s.squish
        pub_date = Date.parse(date_str) rescue nil

        next unless title.match?(EVENT_PATTERN)
        next if title.match?(EXCLUDE_PATTERN)

        { title: title, description: generate_description(title), start_date: pub_date }
      end.uniq { |e| e[:title] }.first(5)
    rescue StandardError => e
      Rails.logger.warn "ClashOfClansEventScraper#scrape_blog: #{e.class}: #{e.message}"
      []
    end

    def generate_description(title)
      case title
      when /clan\s+rush/i
        "The Clan Rush event is live — work together with your Clan to complete event tasks and climb the leaderboard for exclusive cosmetic rewards."
      when /clan\s+games/i
        "Clan Games are back — complete individual challenges to earn points for your Clan and unlock tiered rewards including Magic Items and cosmetics."
      when /gold\s+pass|season\s+challenge|new\s+season|season\s+begins/i
        "A new Clash of Clans season begins — the Gold Pass launches with themed cosmetics, season challenges, and exclusive builder skin rewards."
      when /town\s+hall\s+\d+/i
        "A new Town Hall level arrives — bringing new defenses, troops, upgrades, and a fresh wave of content for veteran Clashers to unlock."
      when /builder\s+base/i
        "The Builder Base receives a major update — with new buildings, upgraded troops, and fresh progression content."
      when /super\s+troop/i
        "Super Troops are on discount — temporarily boost your favourite troops to their powered-up Super form for a reduced Dark Elixir cost."
      when /anniversary/i
        "Clash of Clans' anniversary celebration — featuring free rewards, returning limited-time content, and community milestones."
      when /collab|collaboration/i
        "A major crossover collaboration arrives in Clash of Clans — bringing branded cosmetics, a themed event, and limited-time rewards."
      else
        "An official Clash of Clans in-game event — #{title}."
      end
    end
  end
end
