require "open-uri"
require "json"

# Scrapes upcoming Dota 2 events with a focus on what casual players care about:
#   - The International (annual world championship — the biggest event in Dota 2)
#   - Battle Pass (annual cosmetic/event pass with Arcana vote and community goals)
#   - Annual in-game events: Diretide (Halloween), Frostivus (Winter), Spring event
#   - Major crossover collaborations
#
# Source: Steam Community Announcements API (App ID 570)
# Note: Valve announces events at or near launch. Articles from the last 45 days
#       that are still active are treated as ongoing (no end date).
module EventScrapers
  class Dota2EventScraper
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }.freeze

    STEAM_API_URL = "https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/" \
                    "?appid=570&count=30&maxlength=0&format=json" \
                    "&feeds=steam_community_announcements".freeze

    EXCLUDE_PATTERN = /
      \d+\.\d+[a-z]?\s+gameplay\s+patch |
      gameplay\s+patch                   |
      patch\s+notes                      |
      short\s+film\s+contest             |
      collector.s\s+cache\s+voting       |
      broadcast\s+(rfp|license)          |
      bundles\s+and\s+predictions        |
      streams.*secret\s+shop
    /xi.freeze

    EVENT_PATTERN = /
      the\s+international  |
      battle\s+pass        |
      diretide             |
      frostivus            |
      springs?\s+forward   |
      aghanim              |
      dota\s+x\s+          |   # collabs like "Dota x Monster Hunter"
      grand\s+champions    |
      arrives\b            |
      event\b
    /xi.freeze

    RECENT_DAYS = 45

    def call
      items = fetch_announcements
      events = build_events(items)
      Rails.logger.info "EventScrapers::Dota2EventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::Dota2EventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def fetch_announcements
      raw  = URI.open(STEAM_API_URL, HEADERS).read
      data = JSON.parse(raw)
      data.dig("appnews", "newsitems") || []
    rescue StandardError => e
      Rails.logger.warn "Dota2EventScraper#fetch_announcements: #{e.class}: #{e.message}"
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
          start_date:  nil  # Valve announces on or near launch; treat as ongoing/upcoming
        }
      end.uniq { |e| e[:title] }.first(3)
    end

    def generate_description(title)
      case title
      when /the\s+international/i
        "The International — Dota 2's annual world championship where the best teams in the world compete for the Aegis of Champions and the largest prize pool in esports history. All players receive in-game rewards during the event."
      when /battle\s+pass/i
        "The Dota 2 Battle Pass launches — featuring a new Arcana cosmetic vote, hundreds of exclusive item rewards, community milestones, and a seasonal in-game event for all players."
      when /diretide/i
        "Diretide returns — the annual Halloween event pitting players against Roshan in a candy-stealing game mode, with exclusive Diretide-themed cosmetics and item rewards."
      when /frostivus/i
        "Frostivus is here — the winter holiday celebration with themed cosmetics, gifting mechanics, and limited-time winter game modes."
      when /springs?\s+forward/i
        "Dota 2 Springs Forward — the annual spring event with themed cosmetics, community challenges, and limited-time content."
      when /dota\s+x\s+/i
        "A major Dota 2 crossover collaboration — bringing branded hero cosmetics, a themed event, and limited-time in-game content."
      else
        "An official Dota 2 event — #{title}."
      end
    end
  end
end
