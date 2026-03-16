require "open-uri"
require "json"

# Scrapes current GTA Online events for casual players:
#   - Current bonus GTA$ events (triple rewards, free money gifts)
#   - Major content drops (new heists, safehouses, DLC updates)
#   - Seasonal events (Festive Surprise, Halloween week)
#
# Source: Steam Community Announcements API (App ID 271590)
# Rockstar posts every week — articles within 21 days are treated as active/ongoing.
module EventScrapers
  class GtaOnlineEventScraper
    HEADERS = {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }.freeze

    STEAM_API_URL = "https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/" \
                    "?appid=271590&count=20&maxlength=0&format=json" \
                    "&feeds=steam_community_announcements".freeze

    # Worth surfacing to a casual player
    EVENT_PATTERN = /
      triple\s+reward    |
      3x\s+reward        |
      double\s+reward    |
      2x\s+reward        |
      bonus\s+gta\$      |
      gta\$.*gift        |
      gift.*playing      |
      free.*gta\$        |
      \$1[,.]000[,.]000  |
      community\s+series |
      showcase           |
      raid\b             |
      heist              |
      safehouse          |
      festive            |
      halloween          |
      new\s+update       |
      now\s+available    |
      dlc\b
    /xi.freeze

    # Weekly vehicle/cosmetic drops — not meaningful events for casual players
    EXCLUDE_PATTERN = /
      livery\b           |
      new\s+livery       |
      tuning\b           |
      outfit\s+the       |
      wrap\s+the         |
      arrive[sd]?\s+for  |
      cozy\s+up          |
      redefine\s+breaking|
      bikers?\s+earn     |
      break\s+up\s+rival |
      superyacht\s+life  |
      luxury\s+at\s+the
    /xi.freeze

    RECENT_DAYS = 21

    def call
      items = fetch_announcements
      events = build_events(items)
      Rails.logger.info "EventScrapers::GtaOnlineEventScraper: #{events.size} events"
      events
    rescue StandardError => e
      Rails.logger.warn "EventScrapers::GtaOnlineEventScraper: failed — #{e.class}: #{e.message}"
      []
    end

    private

    def fetch_announcements
      raw  = URI.open(STEAM_API_URL, HEADERS).read
      data = JSON.parse(raw)
      data.dig("appnews", "newsitems") || []
    rescue StandardError => e
      Rails.logger.warn "GtaOnlineEventScraper#fetch_announcements: #{e.class}: #{e.message}"
      []
    end

    def build_events(items)
      cutoff = RECENT_DAYS.days.ago.to_date

      items.filter_map do |item|
        title    = item["title"].to_s.squish
        pub_date = Time.at(item["date"].to_i).to_date rescue nil

        next if title.blank?
        next unless title.match?(EVENT_PATTERN)
        next if title.match?(EXCLUDE_PATTERN)
        next if pub_date && pub_date < cutoff

        {
          title:       title,
          description: generate_description(title),
          start_date:  nil  # weekly events rotate; treat as currently active
        }
      end.uniq { |e| e[:title] }.first(3)
    end

    def generate_description(title)
      case title
      when /triple|3x|double|2x/i
        "Rockstar is running a bonus rewards event in GTA Online — earn significantly more GTA$ and RP on featured activities this week. A great time to grind your favourite businesses or missions."
      when /gift|playing|\$1[,.]000[,.]000/i
        "Rockstar is gifting free GTA$ to all players who log in during this period — simply load into GTA Online to claim your bonus cash automatically."
      when /community\s+series|showcase/i
        "The GTA Online Community Series Showcase is live — play featured community-created jobs and modes for triple rewards and exclusive bonuses this week."
      when /raid/i
        "A new GTA Online Raid is available — team up with friends for a multi-stage heist with big GTA$ payouts and exclusive vehicle and clothing rewards."
      when /safehouse/i
        "New GTA Online content is live — a new property or safehouse has been added to Los Santos with unique missions, customisation options, and earning potential."
      when /festive|christmas/i
        "The Festive Surprise returns to GTA Online — the annual holiday event with free gifts, returning limited-time vehicles, snow in Los Santos, and bonus GTA$."
      when /halloween/i
        "Halloween arrives in GTA Online — spooky limited-time modes, bonus rewards on adversary modes, and free Halloween masks and outfits to claim."
      else
        "An official GTA Online update — #{title}."
      end
    end
  end
end
