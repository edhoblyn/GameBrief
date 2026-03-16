require "open-uri"
require "json"

# Scrapes upcoming Destiny 2 events with a focus on what casual players care about:
#   - Episode / Season launches (new story, weapons, exotic gear)
#   - Annual in-game events: Guardian Games, Solstice, Festival of the Lost, The Dawning
#   - Dungeon and Raid releases
#   - Iron Banner (PvP pinnacle loot)
#
# Source: Steam Community Announcements API (App ID 1085660)
# Note: Bungie announces events on or just before launch. Articles from the last 45 days
#       that are still active are treated as ongoing (no end date).
module EventScrapers
  class Destiny2EventScraper
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }.freeze

    STEAM_API_URL = "https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/" \
                    "?appid=1085660&count=30&maxlength=0&format=json" \
                    "&feeds=steam_community_announcements".freeze

    # Skip weekly blog posts and minor technical posts
    EXCLUDE_PATTERN = /
      this\s+week\s+in\s+destiny |
      sandbox\s+tuning           |
      vidoc\b                    |
      cinematic\s+trailer        |
      launch\s+trailer           |
      reveal\s+trailer           |
      developer\s+livestream     |
      open\s+access\s+week
    /xi.freeze

    # Events worth surfacing to casual players
    EVENT_PATTERN = /
      episode          |
      season           |
      dungeon          |
      raid\b           |
      solstice         |
      dawning          |
      festival\s+of\s+the\s+lost |
      guardian\s+games |
      iron\s+banner    |
      update\b         |
      event\b
    /xi.freeze

    RECENT_DAYS = 45

    def call
      items = fetch_announcements
      events = build_events(items)
      Rails.logger.info "EventScrapers::Destiny2EventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::Destiny2EventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def fetch_announcements
      raw  = URI.open(STEAM_API_URL, HEADERS).read
      data = JSON.parse(raw)
      data.dig("appnews", "newsitems") || []
    rescue StandardError => e
      Rails.logger.warn "Destiny2EventScraper#fetch_announcements: #{e.class}: #{e.message}"
      []
    end

    def build_events(items)
      cutoff = RECENT_DAYS.days.ago.to_date

      items.filter_map do |item|
        title    = item["title"].to_s.squish
        pub_date = Time.at(item["date"].to_i).to_date rescue nil

        next if title.blank?
        next if title.match?(EXCLUDE_PATTERN)
        next unless title.match?(EVENT_PATTERN)
        next if pub_date && pub_date < cutoff

        {
          title:       title,
          description: generate_description(title),
          start_date:  nil  # Bungie announces on launch day; treat as ongoing
        }
      end.uniq { |e| e[:title] }.first(4)
    end

    def generate_description(title)
      case title
      when /episode/i
        "A new Destiny 2 Episode launches — bringing a new story campaign, seasonal activities, exotic weapons, and a fresh artifact mod to unlock."
      when /season/i
        "A new Destiny 2 Season begins — with new seasonal challenges, exotic gear to chase, and a seasonal activity to run each week."
      when /dungeon/i
        "A new Destiny 2 Dungeon goes live — a 3-player endgame challenge with unique encounters, exclusive exotic loot, and a pinnacle reward."
      when /raid/i
        "A new Destiny 2 Raid is available — the pinnacle 6-player co-op challenge with world-first race, exclusive armor sets, and exotic weapons."
      when /guardian\s+games/i
        "Guardian Games is back — Titans, Hunters, and Warlocks compete for class supremacy with daily medals, a community pinnacle event, and exclusive cosmetics."
      when /solstice/i
        "Solstice of Heroes returns — the annual summer event with an armour-glow upgrade system, limited-time activities, and exclusive cosmetics to earn."
      when /festival\s+of\s+the\s+lost/i
        "Festival of the Lost is live — the annual Halloween event with the haunted Haunted Forest activity, themed cosmetics, and free candy rewards."
      when /dawning/i
        "The Dawning returns — the annual winter holiday event where you bake and deliver gifts to NPCs across the solar system for exclusive rewards."
      when /iron\s+banner/i
        "Iron Banner is live — a limited-time PvP playlist where power level matters, featuring pinnacle gear rewards and exclusive Iron Banner weapons."
      else
        "An official Destiny 2 announcement — #{title}."
      end
    end
  end
end
