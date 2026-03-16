require "open-uri"
require "nokogiri"

# Scrapes upcoming EA SPORTS FC 26 events with a focus on what casual players care about:
#   - FUT (Football Ultimate Team) seasonal events: FUT Birthday, Future Stars, TOTS, TOTY
#   - World Tour seasons (new themed player cards)
#   - Fantasy FC and Icon Swaps promo events
#
# Source: ea.com/games/ea-sports-fc/fc-26/news
# Note: EA announces events on launch day. Articles within the last 30 days are treated
#       as ongoing active events (no end date) since FUT promos run for 2-4 weeks.
module EventScrapers
  class EaSportsFc26EventScraper
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }.freeze

    NEWS_URL = "https://www.ea.com/games/ea-sports-fc/fc-26/news".freeze

    EA_TYPE_PREFIX  = /\A(news\s+article|game\s+updates?)/i.freeze
    EA_DATE_PATTERN = /([A-Z][a-z]+ \d{1,2}, \d{4})/

    EVENT_PATTERN = /
      fut\s+birthday      |
      future\s+stars      |
      team\s+of\s+the\s+season |
      tots\b              |
      team\s+of\s+the\s+year   |
      toty\b              |
      world\s+tour        |
      fantasy\s+fc        |
      icon\s+swaps?       |
      knockout\s+royalty  |
      thunderstruck       |
      path\s+to\s+glory   |
      winter\s+wildcards  |
      summer\s+stars      |
      mid-season\s+swap   |
      fc\s+pro\s+live     |
      festival\b
    /xi.freeze

    EXCLUDE_PATTERN = /
      pitch\s+notes?   |
      title\s+update   |
      patch\s+notes?   |
      v\d+\.\d+\.\d+   |
      maintenance
    /xi.freeze

    RECENT_DAYS = 30

    def call
      events = scrape_news
      Rails.logger.info "EventScrapers::EaSportsFc26EventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::EaSportsFc26EventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def scrape_news
      doc    = Nokogiri::HTML(URI.open(NEWS_URL, HEADERS))
      cutoff = RECENT_DAYS.days.ago.to_date

      doc.css("a[href*='/fc-26/news/']").filter_map do |link|
        text = link.text.to_s.squish
        next if text.blank? || text.length < 15 || text.length > 200

        pub_date = text.match(EA_DATE_PATTERN) && Date.parse($1) rescue nil

        clean = text.gsub(EA_TYPE_PREFIX, "")
                    .gsub(EA_DATE_PATTERN, "")
                    .gsub(/Football Ultimate Team[™\s]* 26\s*[-–]\s*/i, "FUT 26 — ")
                    .gsub(/\s*[-–]\s*EA SPORTS Official Site\z/i, "")
                    .squish
        next if clean.blank? || clean.length < 8
        next unless clean.match?(EVENT_PATTERN)
        next if clean.match?(EXCLUDE_PATTERN)
        next if clean.match?(/fantasy\s+fc\s+live/i)  # deduplicate: Live update covered by main Fantasy FC article

        # Recent articles are treated as ongoing active promos (nil = always passes future filter)
        start_date = (pub_date && pub_date >= cutoff) ? nil : pub_date

        { title: clean, description: generate_description(clean), start_date: start_date }
      end.uniq { |e| e[:title] }.first(4)
    rescue StandardError => e
      Rails.logger.warn "EaSportsFc26EventScraper#scrape_news: #{e.class}: #{e.message}"
      []
    end

    def generate_description(title)
      case title
      when /fut\s+birthday/i
        "FUT Birthday is live — player items celebrating the best FUT performances get stat upgrades, and a limited-time themed Squad Building Challenge and Objectives are available."
      when /future\s+stars/i
        "Future Stars is live — special boosted items highlight the most exciting young talents in football with upgraded stats and unique player designs."
      when /team\s+of\s+the\s+season|tots/i
        "Team of the Season has arrived — the best-performing players from leagues around the world receive their highest-rated cards of the year, available through packs and SBCs."
      when /team\s+of\s+the\s+year|toty/i
        "Team of the Year is live — the 23 best players of the calendar year receive special TOTY items, the most coveted cards in FUT."
      when /world\s+tour/i
        "A new World Tour Season is here — themed special player items inspired by a classic international tournament bring unique card designs and boosted stats to FUT."
      when /fantasy\s+fc/i
        "Fantasy FC is live — player items with dynamic upgrades that evolve based on their real-world team performance throughout the promo window."
      when /icon\s+swaps?/i
        "Icon Swaps are available — collect tokens through Objectives and SBCs to exchange them for legendary Icon player items in FUT."
      when /knockout\s+royalty/i
        "Knockout Royalty is live — a special promo celebrating players who shine in cup competitions, with boosted items available through packs and objectives."
      else
        "An official EA SPORTS FC 26 FUT event — #{title}."
      end
    end
  end
end
