require "open-uri"
require "json"

# Scrapes current Helldivers 2 events for casual players:
#   - New Warbond launches (new weapons, armour, stratagems to unlock)
#   - Major Orders (community-wide galactic war objectives)
#   - Seasonal events (Festival of Reckoning, etc.)
#   - Major content updates
#
# Source: Steam Community Announcements API (App ID 553850)
# Arrowhead announces events at launch. Articles within 45 days treated as ongoing.
module EventScrapers
  class Helldivers2EventScraper
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }.freeze

    STEAM_API_URL = "https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/" \
                    "?appid=553850&count=20&maxlength=0&format=json" \
                    "&feeds=steam_community_announcements".freeze

    # Skip patch notes and dev blogs
    EXCLUDE_PATTERN = /
      \Ainto\s+the\s+unjust:\s+[\d.]+   |   # patch titles like "Into the Unjust: 6.0.1"
      \d+\.\d+\.\d+                     |   # any title containing a semver-style version number
      tech\s+blog                       |
      state\s+of\s+the\s+game           |
      large\s+build\s+delist            |
      diving\s+into\s+the\s+development |
      patch\s+\d                        |
      hotfix
    /xi.freeze

    RECENT_DAYS = 45

    def call
      items = fetch_announcements
      events = build_events(items)
      Rails.logger.info "EventScrapers::Helldivers2EventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::Helldivers2EventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def fetch_announcements
      raw  = URI.open(STEAM_API_URL, HEADERS).read
      data = JSON.parse(raw)
      data.dig("appnews", "newsitems") || []
    rescue StandardError => e
      Rails.logger.warn "Helldivers2EventScraper#fetch_announcements: #{e.class}: #{e.message}"
      []
    end

    def build_events(items)
      cutoff = RECENT_DAYS.days.ago.to_date

      items.filter_map do |item|
        title    = item["title"].to_s.squish
        pub_date = Time.at(item["date"].to_i).to_date rescue nil

        next if title.blank?
        next if title.match?(EXCLUDE_PATTERN)
        next if pub_date && pub_date < cutoff

        {
          title:       title,
          description: generate_description(title),
          start_date:  nil  # events are live on announcement; treat as ongoing
        }
      end.uniq { |e| e[:title] }.first(3)
    end

    def generate_description(title)
      case title
      when /warbond/i
        "A new Helldivers 2 Warbond is available — unlock new weapons, armour sets, capes, and stratagems using Medals earned through gameplay. No FOMO — Warbonds never expire."
      when /festival/i
        "A limited-time seasonal event is live in Helldivers 2 — featuring themed in-game content, community challenges, and special rewards for participating Helldivers."
      when /major\s+order|threat|reveal|cyborg|illuminate|terminid|automaton/i
        "A new Major Order has been issued — Super Earth calls all Helldivers to coordinate across the galaxy to complete a shared objective for medals and story progression."
      when /division|regiment|commando|breaker|returns/i
        "New Helldivers 2 content has dropped — a fresh set of weapons, stratagems, or armour is now available to unlock through Warbonds or in-game challenges."
      else
        "An official Helldivers 2 update — #{title}. Log in to see what's new in the galactic war effort."
      end
    end
  end
end
