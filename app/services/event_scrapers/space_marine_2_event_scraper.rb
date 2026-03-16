require "open-uri"
require "json"

# Scrapes upcoming Space Marine 2 events from Steam Community Announcements.
# Includes: community events (XP/currency boosts), Twitch drops, major content updates.
# Excludes: patch notes, hotfixes, community update newsletters, cosmetic DLC releases.
#
# Source: Steam Community Announcements (App ID 2183900)
# Articles within 45 days are treated as ongoing/active (nil date).
module EventScrapers
  class SpaceMarine2EventScraper
    STEAM_URL = "https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=2183900&count=20&feeds=steam_community_announcements".freeze

    RECENT_DAYS = 45

    EVENT_PATTERN = /
      community\s+event       |
      xp\s+boost              |
      currency.*boost         |
      twitch\s+drops?         |
      skulls\b                |
      season\s+\d+            |
      new\s+operation         |
      new\s+chapter           |
      update\s+is\s+live      |
      death\s+or\s+glory      |
      \w+\s+event\s+of\s+\w+
    /xi.freeze

    EXCLUDE_PATTERN = /
      patch\s+notes           |
      hotfix\s+\d+            |
      community\s+update\b    |
      voice\s+pack            |
      dlc\b
    /xi.freeze

    def call
      events = scrape_steam
      Rails.logger.info "EventScrapers::SpaceMarine2EventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::SpaceMarine2EventScraper: failed — #{e.class}: #{e.message}"
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
      Rails.logger.warn "SpaceMarine2EventScraper#scrape_steam: #{e.class}: #{e.message}"
      []
    end

    def generate_description(title)
      case title
      when /community\s+event|xp\s+boost|currency.*boost/i
        "A Space Marine 2 community event is running — earn bonus Requisition and XP across Operations and Eternal War modes for a limited time."
      when /twitch\s+drops?/i
        "Twitch Drops are live for Space Marine 2 — watch partnered streams to earn exclusive cosmetic rewards including skins and accolades."
      when /update\s+is\s+live/i
        "A major Space Marine 2 content update has launched — new missions, chapters, weapons, or cosmetics added to the game for all players."
      when /season\s+\d+/i
        "A new Space Marine 2 season begins — fresh ranked content, new Operations or PvP maps, and season rewards to unlock."
      when /death\s+or\s+glory|\w+\s+event\s+of\s+\w+/i
        "A limited-time Space Marine 2 in-game event is live — complete special challenges for bonus currency, exclusive cosmetics, and event rewards."
      when /skulls/i
        "The Warhammer Skulls Festival is live — the annual digital celebration of Warhammer games with discounts, free content, and community events across all Warhammer titles."
      else
        "An official Space Marine 2 event is live — #{title}."
      end
    end
  end
end
