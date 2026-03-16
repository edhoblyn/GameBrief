require "open-uri"
require "nokogiri"

# Scrapes upcoming League of Legends events for casual players:
#   - New season act launches (Season split structure with themed acts)
#   - New champion releases and reworks
#   - Major international tournaments (First Stand, Worlds)
#   - In-game events (Spirit Blossom, Mythmaker, etc.)
#
# Source: leagueoflegends.com/en-us/news/
# Articles within 30 days are treated as ongoing/active (nil date).
module EventScrapers
  class LeagueOfLegendsEventScraper
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }.freeze

    NEWS_URL = "https://www.leagueoflegends.com/en-us/news/".freeze

    # ISO timestamp embedded in link text: "Category2026-03-13T18:00:00.000ZTitle..."
    TIMESTAMP_PATTERN = /^([\w\s]+?)(\d{4}-\d{2}-\d{2}T[\d:\.Z]+)(.+)/

    # Categories to include
    INCLUDE_CATEGORIES = %w[Game\ Updates Esports].freeze

    # Event keywords for Game Updates articles
    GAME_EVENT_PATTERN = /
      season\s+\w+\s+act   |
      act\s+[IVX\d]+       |
      new\s+champion        |
      champion\s+spotlight  |
      champion\s+update     |
      champion\s+reveal     |
      event\b              |
      spirit\s+blossom      |
      mythmaker             |
      lunar\s+revel         |
      star\s+guardian       |
      high\s+noon           |
      worlds\s+\d+          |
      first\s+stand         |
      mid[\s\-]season\s+invitational |
      msi\b
    /xi.freeze

    # Esports articles worth surfacing (global tournaments only)
    ESPORTS_EVENT_PATTERN = /
      first\s+stand   |
      worlds\s+\d+    |
      world\s+championship |
      mid[\s\-]season\s+invitational |
      msi\b
    /xi.freeze

    EXCLUDE_PATTERN = /
      patch\s+\d+\.\d+\s+notes |
      tft\b                     |
      teamfight\s+tactics       |
      merch\b                   |
      plush\b                   |
      keychain                  |
      figure\b                  |
      tee\b                     |
      new\s+league\s+meta       |   # meta guide articles
      dev:\s+                   |   # developer blogs
      lcs\b | lec\b | lck\b | lpl\b |   # regional splits
      split\s+primer
    /xi.freeze

    RECENT_DAYS = 30

    def call
      events = scrape_news
      Rails.logger.info "EventScrapers::LeagueOfLegendsEventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::LeagueOfLegendsEventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def scrape_news
      doc    = Nokogiri::HTML(URI.open(NEWS_URL, HEADERS))
      cutoff = RECENT_DAYS.days.ago.to_date

      doc.css("a").filter_map do |a|
        text = a.text.to_s.squish
        next unless text =~ TIMESTAMP_PATTERN

        category = $1.strip
        date_str = $2
        raw_rest = $3.strip

        next unless INCLUDE_CATEGORIES.any? { |c| category.downcase.include?(c.downcase) }

        pub_date = Date.parse(date_str) rescue nil
        next if pub_date && pub_date < cutoff

        # Split concatenated title+subtitle at camelCase junction
        title = split_title(raw_rest)
        next if title.blank? || title.length < 8 || title.length > 80

        next if title.match?(EXCLUDE_PATTERN)

        if category =~ /esports/i
          next unless title.match?(ESPORTS_EVENT_PATTERN)
        else
          next unless title.match?(GAME_EVENT_PATTERN)
        end

        { title: title, description: generate_description(title, category), start_date: nil }
      end.uniq { |e| e[:title] }.first(4)
    rescue StandardError => e
      Rails.logger.warn "LeagueOfLegendsEventScraper#scrape_news: #{e.class}: #{e.message}"
      []
    end

    # Split "Season One Act II TrailerThe Kingdom is calling" → "Season One Act II Trailer"
    def split_title(text)
      # Split at first lowercase→uppercase junction (camelCase seam between title and subtitle)
      parts = text.split(/(?<=[a-z0-9])(?=[A-Z])/, 2)
      parts.first.to_s.squish
    end

    def generate_description(title, category)
      case title
      when /act\s+[IVX\d]+|season.*act/i
        "A new League of Legends Season Act is live — bringing a new ranked split, themed cosmetics, an event pass with missions, and limited-time event shop rewards."
      when /champion\s+spotlight|champion\s+reveal|new\s+champion/i
        "A new League of Legends Champion has been released — available to unlock via Blue Essence earned through playing, or with Riot Points."
      when /champion\s+update/i
        "A League of Legends Champion has received a major visual and gameplay update — bringing refreshed abilities, new skins, and updated voice lines."
      when /spirit\s+blossom|mythmaker|lunar\s+revel|star\s+guardian|high\s+noon/i
        "A major League of Legends in-game event is live — featuring a themed event pass, exclusive skin line, missions to complete, and a limited-time event shop."
      when /first\s+stand/i
        "First Stand — the first major international League of Legends tournament of the year. The best teams from every region compete before the Mid-Season Invitational."
      when /worlds|world\s+championship/i
        "The League of Legends World Championship — the biggest event in the LoL calendar where the best teams from every region compete for the Summoner's Cup."
      when /mid[\s\-]season\s+invitational|msi/i
        "The Mid-Season Invitational brings together regional champions for the first international clash of the year, with in-game rewards for all players who watch."
      else
        "An official League of Legends update — #{title}."
      end
    end
  end
end
