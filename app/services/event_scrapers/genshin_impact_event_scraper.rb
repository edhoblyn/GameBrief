require "open-uri"
require "json"

# Scrapes current Genshin Impact events for casual players:
#   - Version launches (new story, new characters, new region areas — every ~6 weeks)
#   - Mid-version phase 2 updates (new character banner, new in-game events)
#   - Major seasonal events (Lantern Rite, Golden Apple Archipelago, anniversary)
#
# Source: HoYoLAB official news API (game_id=2 = Genshin Impact)
# Genshin versions launch every ~42 days. Version articles published on launch day
# are treated as ongoing (nil date) within a 45-day window.
module EventScrapers
  class GenshinImpactEventScraper
    HEADERS = {
      "User-Agent"  => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
      "Accept"      => "application/json"
    }.freeze

    HOYOLAB_API_URL = "https://bbs-api-os.hoyolab.com/community/post/wapi/getNewsList" \
                      "?gids=2&page_size=20&type=1".freeze

    EVENT_PATTERN = /
      version.*update\s+details  |
      update\s+details.*version  |
      maintenance\s+preview       |
      what.s\s+new                |
      lantern\s+rite              |
      golden\s+apple              |
      archipelago                 |
      anniversary                 |
      windblume                   |
      summer\s+event              |
      chronicle\s+of\s+echoes     |
      version\s+preview           |
      special\s+program
    /xi.freeze

    EXCLUDE_PATTERN = /
      third[\s\-]party\s+tool     |
      top[\s\-]up\s+issue         |
      in[\s\-]game\s+issue        |
      issue\s+(fix|summary)       |
      actions\s+taken\s+against   |
      compensation
    /xi.freeze

    RECENT_DAYS = 45

    def call
      items = fetch_news
      events = build_events(items)
      Rails.logger.info "EventScrapers::GenshinImpactEventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::GenshinImpactEventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def fetch_news
      raw  = URI.open(HOYOLAB_API_URL, HEADERS).read
      data = JSON.parse(raw)
      data.dig("data", "list") || []
    rescue StandardError => e
      Rails.logger.warn "GenshinImpactEventScraper#fetch_news: #{e.class}: #{e.message}"
      []
    end

    def build_events(items)
      cutoff   = RECENT_DAYS.days.ago.to_date
      seen_versions = []

      items.filter_map do |item|
        post     = item["post"] || {}
        title    = post["subject"].to_s.squish
        pub_date = Time.at(post["created_at"].to_i).to_date rescue nil

        next if title.blank?
        next if title.match?(EXCLUDE_PATTERN)
        next unless title.match?(EVENT_PATTERN)
        next if pub_date && pub_date < cutoff

        cleaned = clean_title(title)

        # Deduplicate: only one article per version name
        version_key = extract_version_key(title)
        if version_key
          next if seen_versions.include?(version_key)
          seen_versions << version_key
        end

        {
          title:       cleaned,
          description: generate_description(title),
          start_date:  nil  # versions launch on announcement day; treat as ongoing
        }
      end.first(3)
    end

    def extract_version_key(title)
      title.match(/Version\s+"?([A-Za-z0-9 ]+?)"?\s+(Update|Version|Maintenance)/i)&.captures&.first&.strip&.downcase
    end

    # Strip verbose HoYoverse title prefixes
    def clean_title(title)
      # "Song of the Welkin Moon: ...: Version "X" Update Details" → "Genshin Impact Version X — Now Live"
      if title =~ /Version\s+"?([A-Za-z0-9 ]+?)"?\s+Update\s+Details/i
        return "Genshin Impact — Version #{$1.strip} Now Live"
      end
      if title =~ /Version\s+"?([A-Za-z0-9 ]+?)"?\s+Update\s+Maintenance\s+Preview/i
        return "Genshin Impact — Version #{$1.strip} Now Live"
      end
      if title =~ /Version\s+([A-Za-z0-9 ]+?)\s+Version\s+Details.*What.s\s+New/i
        return "Genshin Impact — Version #{$1.strip} Phase 2 Update"
      end
      title.squish
    end

    def generate_description(title)
      case title
      when /maintenance\s+preview|update\s+details|what.s\s+new/i
        version_name = title.match(/Version\s+"?([^"]+?)"?\s+(Update|Version|Maintenance)/i)&.captures&.first
        vname = version_name ? "\"#{version_name}\"" : "the latest"
        "A new Genshin Impact version launches — #{vname} brings new story chapters, new playable characters with their own banner, new in-game events, and fresh Primogems to earn through exploration and challenges."
      when /lantern\s+rite/i
        "Lantern Rite returns — Liyue's annual festival with story quests, a free 4-star character to claim, limited-time minigames, and thousands of Primogems to earn."
      when /golden\s+apple|archipelago/i
        "The Golden Apple Archipelago summer event returns — a temporary island opens with story quests, free 4-star character, sailing mini-games, and exclusive cosmetic rewards."
      when /anniversary/i
        "Genshin Impact's anniversary celebration — featuring free Primogems, a free Intertwined Fate, returning limited-time events, and community milestones."
      when /windblume/i
        "The Windblume Festival is live in Mondstadt — a spring celebration with story quests, free cosmetics, and seasonal mini-games to earn Primogems and rewards."
      else
        "An official Genshin Impact version update — bringing new story content, characters, events, and Primogem rewards."
      end
    end
  end
end
