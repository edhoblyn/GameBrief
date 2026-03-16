require "open-uri"
require "json"

# Scrapes upcoming Overwatch 2 events from Steam Community Announcements.
# Includes: season launches, seasonal events, player appreciation boosts.
# Excludes: cosmetic reveals, animated shorts, hero trials, patch notes.
#
# Source: Steam Community Announcements (App ID 2357570)
# Articles within 45 days are treated as ongoing/active (nil date).
module EventScrapers
  class Overwatch2EventScraper
    STEAM_URL = "https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=2357570&count=20&feeds=steam_community_announcements".freeze

    RECENT_DAYS = 45

    EVENT_PATTERN = /
      season\s+\d+               |
      reign\s+of\s+talon.*season |
      loverwatch                 |
      winter\s+wonderland        |
      halloween\s+terror         |
      summer\s+games             |
      anniversary\b              |
      lunar\s+new\s+year         |
      \d+\s*xp\b                 |
      double\s+xp                |
      player\s+appreciation      |
      lootbox\s+hunt             |
      spotlight\s+livestream     |
      new\s+hero\b
    /xi.freeze

    EXCLUDE_PATTERN = /
      mythic\s+\w+               |
      animated\s+short           |
      cinematic\b                |
      hero\s+trial               |
      patch\s+notes              |
      balance\s+update           |
      \Anew\s+rosters            |
      \Achoose\s+your\s+side     |
      \Athe\s+next\s+big\s+story |
      \Anew\s+map\b
    /xi.freeze

    def call
      events = scrape_steam
      Rails.logger.info "EventScrapers::Overwatch2EventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::Overwatch2EventScraper: failed — #{e.class}: #{e.message}"
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
      Rails.logger.warn "Overwatch2EventScraper#scrape_steam: #{e.class}: #{e.message}"
      []
    end

    def generate_description(title)
      case title
      when /season\s+\d+|reign\s+of\s+talon.*season/i
        "A new Overwatch season is live — fresh Battle Pass content, a new hero or map, balance updates, and a ranked reset. Log in now to claim your free tier rewards."
      when /loverwatch/i
        "Loverwatch returns — the annual Valentine's Day event with limited-time cosmetics, weekly challenges, and themed arcade modes."
      when /winter\s+wonderland/i
        "Winter Wonderland is live — seasonal brawls, returning festive skins, and limited-time holiday cosmetics available for a short time only."
      when /halloween\s+terror/i
        "Halloween Terror is back — spooky skins, Junkenstein's Revenge, and limited cosmetics only available during the haunted season."
      when /summer\s+games/i
        "Summer Games returns — limited athletic-themed skins, Lucioball, and seasonal weekly challenges."
      when /anniversary/i
        "The Overwatch Anniversary event is live — celebrating the game's birthday with returning limited cosmetics, a rotating arcade, and anniversary bundles."
      when /\d+\s*xp|double\s+xp|player\s+appreciation/i
        "A Player Appreciation event is running — bonus XP across all modes and extra challenges to help you level up your Battle Pass faster."
      when /spotlight\s+livestream/i
        "The Overwatch Spotlight livestream previews the upcoming season — new heroes, map reveals, and a look at what's coming in the next Battle Pass."
      when /lootbox\s+hunt/i
        "An in-game hunt event is live — find hidden lootboxes across maps to unlock exclusive limited-time cosmetics and bonus credits."
      when /new\s+hero/i
        "A new Overwatch hero has been revealed — unlock them immediately with the Battle Pass or earn them through free tier progression."
      else
        "An official Overwatch update is live — #{title}."
      end
    end
  end
end
