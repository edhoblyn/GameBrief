require "open-uri"
require "nokogiri"

# Scrapes upcoming Apex Legends events with a focus on what casual players care about:
#   - New season launches (new legend, map changes, ranked reset)
#   - In-game collection events and collaborations
#   - Limited-time modes and Wildcard events
#   - One major esports milestone: the ALGS Championship
#
# Sources:
#   EA news   — https://www.ea.com/games/apex-legends/apex-legends/news
#   Liquipedia — ALGS schedule (Championship date only)
module EventScrapers
  class ApexLegendsEventScraper
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }.freeze

    EA_NEWS_URL       = "https://www.ea.com/games/apex-legends/apex-legends/news".freeze
    ALGS_SCHEDULE_URL = "https://liquipedia.net/apexlegends/Apex_Legends_Global_Series/2026-27/Schedule".freeze

    # In-game articles worth surfacing to casual players
    INGAME_PATTERN = /
      new\s+season       |
      season\s+\d+       |
      breach             |   # season name examples — expand as needed
      collection\s+event |
      limited[\s\-]time  |
      wildcard           |
      collab             |
      collaboration      |
      anniversary        |
      star\s+wars        |
      event\b
    /xi.freeze

    # Things that are NOT casual-player events
    EXCLUDE_PATTERN = /
      patch\s+notes?     |
      designer.s\s+notes |
      anti[\s\-]cheat    |
      matchmaking        |
      nintendo\s+switch  |
      road\s+ahead       |
      the\s+road\s+ahead
    /xi.freeze

    # EA link text format: "News ArticleMarch 3, 2026Title Here"
    EA_TYPE_PREFIX = /\A(news\s+article|game\s+updates?)/i.freeze
    EA_DATE_PATTERN = /([A-Z][a-z]+ \d{1,2}, \d{4})/

    def call
      ingame       = scrape_ingame_events
      championship = scrape_algs_championship
      combined     = (ingame + championship).uniq { |e| e[:title].downcase }
      Rails.logger.info "EventScrapers::ApexLegendsEventScraper: #{combined.size} events (#{ingame.size} in-game, #{championship.size} ALGS)"
      combined
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::ApexLegendsEventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    # ------------------------------------------------------------------
    # EA news — seasons, collection events, collabs, Wildcard modes
    # ------------------------------------------------------------------
    def scrape_ingame_events
      doc = Nokogiri::HTML(URI.open(EA_NEWS_URL, HEADERS))

      doc.css("a[href]").filter_map do |link|
        href = link["href"].to_s.strip
        text = link.text.to_s.squish

        next if href.blank? || text.blank?
        next unless href.include?("/games/apex-legends/")
        next if text.length < 10 || text.length > 150

        # Extract publish date from embedded text: "News ArticleMarch 3, 2026Title"
        pub_date = text.match(EA_DATE_PATTERN) && Date.parse($1) rescue nil

        clean = text.gsub(EA_TYPE_PREFIX, "")
                    .gsub(EA_DATE_PATTERN, "")
                    .squish
        next if clean.blank? || clean.length < 10

        next unless clean.match?(INGAME_PATTERN)
        next if clean.match?(EXCLUDE_PATTERN)

        { title: clean, description: generate_ingame_description(clean), start_date: pub_date }
      end.uniq { |e| e[:title] }.first(5)
    rescue StandardError => e
      Rails.logger.warn "ApexLegendsEventScraper#scrape_ingame_events: #{e.class}: #{e.message}"
      []
    end

    # ------------------------------------------------------------------
    # Liquipedia — Championship only (the one ALGS event casual fans know)
    # ------------------------------------------------------------------
    def scrape_algs_championship
      doc  = Nokogiri::HTML(URI.open(ALGS_SCHEDULE_URL, HEADERS))
      rows = doc.css("table.wikitable tr")

      current_year = Time.current.year
      results      = []

      rows.each do |row|
        cells = row.css("td, th").map { |c| c.text.squish }
        next if cells.empty?

        if cells.size == 1 && cells[0].match?(/\A\d{4}\z/)
          current_year = cells[0].to_i
          next
        end

        next if cells[0] == "Date"

        date_str, title, location = cells
        next unless title.to_s.match?(/\Achampionship\z/i)

        start_date = parse_algs_date(date_str, current_year)
        desc = "The ALGS Year 6 World Championship — the season finale where the best Apex Legends teams in the world compete for the grand prize."
        desc += " Location: #{location}." if location.present?

        results << { title: "ALGS World Championship", description: desc, start_date: start_date }
      end

      results
    rescue StandardError => e
      Rails.logger.warn "ApexLegendsEventScraper#scrape_algs_championship: #{e.class}: #{e.message}"
      []
    end

    def generate_ingame_description(title)
      case title
      when /season\s+\d+|new\s+season/i
        "A new Apex Legends season arrives — bringing a new or reworked Legend, map changes, a fresh Battle Pass, and a ranked reset."
      when /collection\s+event/i
        "A limited-time Collection Event with exclusive cosmetics, a themed game mode, and free rewards for completing challenges."
      when /anniversary/i
        "Apex Legends' anniversary celebration — featuring free rewards, returning limited-time modes, and community highlights."
      when /wildcard/i
        "A Wildcard limited-time mode shakes up the Battle Royale formula with a unique ruleset for a limited window."
      when /collab|collaboration|star\s+wars/i
        "A major crossover collaboration bringing branded cosmetics, a themed mode, and limited-time rewards to Apex Legends."
      else
        "An official Apex Legends in-game event — #{title}."
      end
    end

    def parse_algs_date(date_str, year)
      return nil if date_str.blank?
      start_part = date_str.include?(" - ") ? date_str.split(" - ").first.strip : date_str.split("-").first.strip
      Date.parse("#{start_part} #{year}")
    rescue ArgumentError, TypeError
      nil
    end
  end
end
