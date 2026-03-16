require "open-uri"
require "json"

# Scrapes upcoming PUBG: Battlegrounds events from Steam Community Announcements.
# Includes: anniversary events, seasonal fests, esports series launches.
# Excludes: weekly ban notices, patch notes, store updates, anti-cheat letters.
#
# Source: Steam Community Announcements (App ID 578080)
# Articles within 45 days are treated as ongoing/active (nil date).
module EventScrapers
  class PubgEventScraper
    STEAM_URL = "https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=578080&count=20&feeds=steam_community_announcements".freeze

    RECENT_DAYS = 45

    EVENT_PATTERN = /
      anniversary             |
      spring\s+fest           |
      summer\s+\w+            |
      winter\s+\w+            |
      survivor\s+pass         |
      global\s+series         |
      global\s+championship   |
      ranked\s+season         |
      season\s+\d+            |
      new\s+map               |
      vikendi|erangel|miramar|taego|rondo|deston|sanhok
    /xi.freeze

    EXCLUDE_PATTERN = /
      weekly\s+bans?          |
      ban\s+notice            |
      patch\s+notes           |
      map\s+service\s+report  |
      store\s+update          |
      dev\s+letter            |
      anti[- ]cheat           |
      player\s+of\s+the\s+day |
      mission\s+:             |
      first\s+party\s+impressions
    /xi.freeze

    def call
      events = scrape_steam
      Rails.logger.info "EventScrapers::PubgEventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::PubgEventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def scrape_steam
      json   = URI.open(STEAM_URL).read
      items  = JSON.parse(json).dig("appnews", "newsitems") || []
      cutoff = RECENT_DAYS.days.ago.to_date

      items.filter_map do |item|
        title    = item["title"].to_s.strip
        pub_date = Time.at(item["date"].to_i).to_date

        next if pub_date < cutoff
        next if title.match?(EXCLUDE_PATTERN)
        next unless title.match?(EVENT_PATTERN)

        start_date = pub_date >= Date.today ? pub_date : nil
        { title: title, description: generate_description(title), start_date: start_date }
      end.uniq { |e| e[:title] }.first(4)
    rescue StandardError => e
      Rails.logger.warn "PubgEventScraper#scrape_steam: #{e.class}: #{e.message}"
      []
    end

    def generate_description(title)
      case title
      when /anniversary/i
        "PUBG is celebrating its anniversary — log in for limited-time missions, free cosmetic rewards, and anniversary-themed events running for a limited time."
      when /spring\s+fest/i
        "Spring Fest is live — seasonal missions, exclusive cosmetics, and limited-time bonuses available for a short window to kick off the new season."
      when /global\s+series/i
        "The PUBG Global Series has launched — the international esports circuit where regional teams compete for a share of the world-level prize pool."
      when /global\s+championship/i
        "The PUBG Global Championship — the end-of-year world title event where the best teams from every region compete for the biggest prize pool in PUBG esports."
      when /survivor\s+pass/i
        "A new Survivor Pass is live — complete missions to earn exclusive cosmetics, XP boosts, and limited skins only available during the pass period."
      when /ranked\s+season/i
        "A new PUBG Ranked Season begins — fresh MMR resets, updated ranked rewards, and a new set of end-of-season cosmetics to earn."
      when /season\s+\d+/i
        "A new PUBG season has launched — new content, balance changes, and fresh progression rewards across all modes."
      when /vikendi|erangel|miramar|taego|rondo|deston|sanhok/i
        "A map update is live in PUBG — featuring reworks, new zones, or rotation changes that shake up the battle royale experience."
      else
        "An official PUBG event is live — #{title}."
      end
    end
  end
end
