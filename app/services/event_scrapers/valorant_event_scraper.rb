require "open-uri"
require "nokogiri"

# Scrapes upcoming Valorant esports events from vlr.gg and in-game events
# from the official Valorant news page.
#
# Returns an array of hashes:
#   { title: String, description: String, start_date: Date or nil }
module EventScrapers
  class ValorantEventScraper
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
      "Accept-Language" => "en-US,en;q=0.9"
    }.freeze

    VLR_EVENTS_URL  = "https://www.vlr.gg/events".freeze
    NEWS_URL        = "https://playvalorant.com/en-us/news/".freeze

    # Match main-circuit VCT events only.
    # Excludes Challengers (regional development circuit) and minor cups.
    VCT_PATTERN = /\bvct\b.*stage|\bvct\b.*kickoff|valorant (?:masters|champions)|game changers.*championship/i.freeze

    # Broader pattern to detect VCT-branded events not already matched
    VCT_BROAD_PATTERN = /\bvct\b|valorant masters|valorant champions/i.freeze

    # Title must NOT match these to be included (filters out lower-tier events)
    VCT_EXCLUDE_PATTERN = /challengers|cash cup|promotion|relegation|open qualifier/i.freeze

    # In-game events: act launches, new agents, night market
    # Exclude patch notes (already handled by the patch scraper)
    INGAME_PATTERN  = /new agent|night[\s.]?market|act \d+|episode \d+|new map/i.freeze
    PATCH_PATTERN   = /patch notes?/i.freeze

    DESCRIPTIONS = {
      /kickoff/i    => "The VCT 2026 Kickoff — the opening competitive tournament where partnered teams compete for early-season points.",
      /masters/i    => "A premier VCT 2026 international LAN, bringing top teams from every region to compete on the biggest stage.",
      /stage 1/i    => "VCT 2026 Stage 1 — weeks of regional competition where partnered teams earn points toward Masters qualification.",
      /stage 2/i    => "VCT 2026 Stage 2 — the second qualification stage as teams push to lock in their spots at Champions.",
      /champions/i  => "VALORANT Champions 2026 — the season-ending world championship that crowns the best team on the planet.",
      /game changers/i => "VCT Game Changers Championship — the premiere global event for women and underrepresented genders in Valorant esports.",
    }.freeze

    def call
      esports = scrape_esports_events
      ingame  = scrape_ingame_events
      combined = (esports + ingame).uniq { |e| e[:title].downcase }
      Rails.logger.info "EventScrapers::ValorantEventScraper: found #{combined.size} events (#{esports.size} esports, #{ingame.size} in-game)"
      combined
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::ValorantEventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    # ------------------------------------------------------------------
    # VLR.gg — upcoming Valorant esports events
    # ------------------------------------------------------------------
    def scrape_esports_events
      doc = Nokogiri::HTML(URI.open(VLR_EVENTS_URL, HEADERS))

      # VLR.gg wraps each event in an <a> with class "event-item-wf-link"
      # Fallback to any .event-item container.
      items = doc.css("a.event-item-wf-link")
      items = doc.css(".event-item") if items.empty?

      items.filter_map do |item|
        title_el = item.at_css(".event-item-title")
        date_el  = item.at_css(".event-item-desc-item.mod-dates, [class*='mod-date']")

        next unless title_el
        title = title_el.text.squish
        next if title.blank?
        next unless title.match?(VCT_BROAD_PATTERN)
        next if title.match?(VCT_EXCLUDE_PATTERN)

        start_date  = parse_start_date(date_el&.text)
        description = generate_description(title)

        { title: title, description: description, start_date: start_date }
      end.uniq { |e| e[:title] }
    rescue StandardError => e
      Rails.logger.warn "ValorantEventScraper#scrape_esports_events: #{e.class}: #{e.message}"
      []
    end

    # ------------------------------------------------------------------
    # playvalorant.com/news — in-game events (act launches, agent drops, etc.)
    # Excludes patch notes since those go through the patch scraper pipeline.
    # ------------------------------------------------------------------
    def scrape_ingame_events
      doc = Nokogiri::HTML(URI.open(NEWS_URL, HEADERS))

      doc.css("a[href]").filter_map do |link|
        href = link["href"].to_s.strip
        text = link.text.to_s.squish

        next if href.blank? || text.blank?
        next if text.length < 10 || text.length > 120   # skip nav labels and JSON blobs
        next if text.match?(/\d{4}-\d{2}-\d{2}/)        # skip ISO-date strings
        next unless href.include?("/news/")
        next if text.match?(PATCH_PATTERN)
        next unless text.match?(INGAME_PATTERN)

        description = "Official Valorant in-game event: #{text}."
        { title: text, description: description, start_date: nil }
      end.uniq { |e| e[:title] }.first(4)
    rescue StandardError => e
      Rails.logger.warn "ValorantEventScraper#scrape_ingame_events: #{e.class}: #{e.message}"
      []
    end

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def generate_description(title)
      DESCRIPTIONS.each do |pattern, desc|
        return desc if title.match?(pattern)
      end
      "An official VCT 2026 Valorant esports event."
    end

    # Parses the start date from VLR.gg date strings like:
    #   "Mar 31 — May 24"
    #   "Mar 31 — May 24, 2026"
    #   "Sep 24 – Oct 18, 2026"
    def parse_start_date(date_str)
      return nil if date_str.blank?

      # Take only the start portion (before the em-dash or hyphen)
      start_part = date_str.split(/[—–-]/).first.to_s.squish
      # Strip icon characters and extra whitespace
      start_part = start_part.gsub(/[^\w\s,]/, "").squish
      return nil if start_part.blank?

      # Append current year if none present
      start_part = "#{start_part}, #{Time.current.year}" unless start_part.match?(/\d{4}/)

      Date.parse(start_part)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
