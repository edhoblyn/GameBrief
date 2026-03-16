require "open-uri"
require "json"

# Scrapes upcoming Counter-Strike 2 events with a focus on what casual players care about:
#   - Operations (multi-month story/mission content packs — the biggest casual events in CS2)
#   - CS2 Majors (the 2 big world championship events per year)
#   - Special in-game events and case releases
#
# Source: Steam Community Announcements API (App ID 730)
# Note: Valve announces operations on launch day, not in advance. Operations run for months,
#       so articles posted within the last 90 days are treated as ongoing (no end date).
module EventScrapers
  class CounterStrike2EventScraper
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }.freeze

    STEAM_API_URL = "https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/" \
                    "?appid=730&count=30&maxlength=0&format=json" \
                    "&feeds=steam_community_announcements".freeze

    # Titles to skip — patch notes and minor feature announcements
    EXCLUDE_PATTERN = /
      \Acounter-strike\s+2\s+update\z  |
      \Acs2\s+workshop\s+update\z      |
      service\s+medal                  |
      introducing\s+true\s*view        |
      true\s*view
    /xi.freeze

    # Major tournament keywords — 1 per season max
    MAJOR_PATTERN = /major|championship|playoffs/i.freeze

    # Operations are short creative names (not matching update/patch/medal patterns)
    OPERATION_MAX_DAYS = 45

    def call
      items = fetch_announcements
      events = build_events(items)
      Rails.logger.info "EventScrapers::CounterStrike2EventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::CounterStrike2EventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def fetch_announcements
      raw  = URI.open(STEAM_API_URL, HEADERS).read
      data = JSON.parse(raw)
      data.dig("appnews", "newsitems") || []
    rescue StandardError => e
      Rails.logger.warn "CounterStrike2EventScraper#fetch_announcements: #{e.class}: #{e.message}"
      []
    end

    def build_events(items)
      majors_added = 0
      cutoff = OPERATION_MAX_DAYS.days.ago.to_date

      items.filter_map do |item|
        title    = item["title"].to_s.squish
        pub_date = Time.at(item["date"].to_i).to_date rescue nil

        next if title.blank?
        next if title.match?(EXCLUDE_PATTERN)

        if title.match?(MAJOR_PATTERN)
          next if majors_added >= 1
          next if pub_date && pub_date < Date.today

          majors_added += 1
          {
            title:       title,
            description: generate_major_description(title),
            start_date:  pub_date
          }
        else
          # Operation / special event — only include if recent enough to still be active
          next if pub_date && pub_date < cutoff

          {
            title:       title,
            description: generate_operation_description(title),
            start_date:  nil  # operations are ongoing; no fixed end date
          }
        end
      end.uniq { |e| e[:title] }.first(4)
    end

    def generate_operation_description(title)
      "CS2 Operation: #{title} — a limited-time content pack with exclusive missions, weapon cases, sticker capsules, and a premium Operation Pass for bonus rewards and coin progression."
    end

    def generate_major_description(title)
      "The CS2 Major Championship — the biggest Counter-Strike tournament of the season, featuring 24 of the world's best teams competing for the trophy, a $1.25M prize pool, and in-game viewer rewards for all players."
    end
  end
end
