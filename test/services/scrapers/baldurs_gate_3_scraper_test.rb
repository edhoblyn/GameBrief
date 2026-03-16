require "test_helper"

class Scrapers::BaldursGate3ScraperTest < ActiveSupport::TestCase
  test "collects official baldur's gate 3 patch updates from steam news data" do
    travel_to Time.zone.local(2026, 3, 16, 12, 0, 0) do
      scraper = Scrapers::BaldursGate3Scraper.new
      html = index_html
      scraper.define_singleton_method(:fetch_document) do |_url|
        Nokogiri::HTML(html)
      end

      results = scraper.call

      assert_equal 5, results.size

      latest_patch = results.first
      assert_equal "Hotfix #35 Now Live!", latest_patch[:title]
      assert_equal "https://store.steampowered.com/news/app/1086940/view/568143233911096621", latest_patch[:source_url]
      assert_equal Time.zone.parse("2025-11-20T15:25:00+00:00").to_i, latest_patch[:published_at].to_i
      assert_includes latest_patch[:content], "Crashes and Performance"
      assert_includes latest_patch[:content], "- Fixed a crash when changing input mode."

      hotfix_34 = results.second
      assert_equal "Hotfix #34 Now Live!", hotfix_34[:title]
      assert_equal Time.zone.parse("2025-09-23T14:27:00+00:00").to_i, hotfix_34[:published_at].to_i
      assert_includes hotfix_34[:content], "- Fixed Shadowheart's spear tooltip."

      room_temperature_fix = results.third
      assert_equal "Room Temperature Fix #33 Now Live!", room_temperature_fix[:title]
      assert_equal Time.zone.parse("2025-07-31T13:30:00+00:00").to_i, room_temperature_fix[:published_at].to_i
      assert_includes room_temperature_fix[:content], "Gameplay"
      assert_includes room_temperature_fix[:content], "- Fixed the host getting stuck in dialogue."

      cross_play_update = results.fourth
      assert_equal "Community Update #34 - Connecting With Cross-Play & Hotfix #32", cross_play_update[:title]
      assert_equal Time.zone.parse("2025-05-20T15:08:00+00:00").to_i, cross_play_update[:published_at].to_i
      assert_includes cross_play_update[:content], "Cross-play"
      assert_includes cross_play_update[:content], "- Improved cross-play party invites."

      final_patch = results.fifth
      assert_equal "The Final Patch: New Subclasses, Photo Mode, and Cross-Play", final_patch[:title]
      assert_equal Time.zone.parse("2025-04-15T14:36:00+00:00").to_i, final_patch[:published_at].to_i
      assert_includes final_patch[:content], "New Subclasses"
      assert_includes final_patch[:content], "- Added Photo Mode."
    end
  end

  private

  def index_html
    hotfix_35_time = Time.zone.parse("2025-11-20T15:25:00+00:00").to_i
    hotfix_34_time = Time.zone.parse("2025-09-23T14:27:00+00:00").to_i
    room_temperature_fix_time = Time.zone.parse("2025-07-31T13:30:00+00:00").to_i
    cross_play_update_time = Time.zone.parse("2025-05-20T15:08:00+00:00").to_i
    final_patch_time = Time.zone.parse("2025-04-15T14:36:00+00:00").to_i
    stale_time = Time.zone.parse("2025-03-01T12:00:00+00:00").to_i

    payload = {
      "documents" => [
        { "unique_id" => "568143233911096621", "event_type" => 12, "start_time" => hotfix_35_time },
        { "unique_id" => "511843343389426278", "event_type" => 12, "start_time" => hotfix_34_time },
        { "unique_id" => "538855872766412727", "event_type" => 12, "start_time" => room_temperature_fix_time },
        { "unique_id" => "574882869963392186", "event_type" => 28, "start_time" => cross_play_update_time },
        { "unique_id" => "538849539213231622", "event_type" => 14, "start_time" => final_patch_time },
        { "unique_id" => "111111111111111111", "event_type" => 12, "start_time" => stale_time }
      ],
      "events" => [
        event_payload(
          gid: "568143233911096621",
          event_type: 12,
          published_at: "2025-11-20T15:25:00+00:00",
          headline: "Hotfix #35 Now Live!",
          body: <<~BODY
            [h3]Crashes and Performance[/h3]
            [list]
            [*]Fixed a crash when changing input mode.
            [*]Reduced stalls while loading crowded saves.
            [/list]
          BODY
        ),
        event_payload(
          gid: "511843343389426278",
          event_type: 12,
          published_at: "2025-09-23T14:27:00+00:00",
          headline: "Hotfix #34 Now Live!",
          body: <<~BODY
            [h3]UI[/h3]
            [list]
            [*]Fixed Shadowheart's spear tooltip.
            [/list]
          BODY
        ),
        event_payload(
          gid: "538855872766412727",
          event_type: 12,
          published_at: "2025-07-31T13:30:00+00:00",
          headline: "Room Temperature Fix #33 Now Live!",
          body: <<~BODY
            [h2]Gameplay[/h2]
            [list]
            [*]Fixed the host getting stuck in dialogue.
            [*]Fixed a save issue in co-op.
            [/list]
          BODY
        ),
        event_payload(
          gid: "574882869963392186",
          event_type: 28,
          published_at: "2025-05-20T15:08:00+00:00",
          headline: "Community Update #34 - Connecting With Cross-Play & Hotfix #32",
          body: <<~BODY
            [h2]Cross-play[/h2]
            [list]
            [*]Improved cross-play party invites.
            [*]Fixed a multiplayer crash during reconnect.
            [/list]
          BODY
        ),
        event_payload(
          gid: "538849539213231622",
          event_type: 14,
          published_at: "2025-04-15T14:36:00+00:00",
          headline: "The Final Patch: New Subclasses, Photo Mode, and Cross-Play",
          body: <<~BODY
            [h2]New Subclasses[/h2]
            [list]
            [*]Added Photo Mode.
            [*]Added 12 new subclasses.
            [/list]
          BODY
        ),
        event_payload(
          gid: "222222222222222222",
          event_type: 28,
          published_at: "2025-12-01T11:33:00+00:00",
          headline: "Community Update #36 A Very Moddy Christmas",
          body: "[list][*]Seasonal mod spotlight.[/list]"
        ),
        event_payload(
          gid: "111111111111111111",
          event_type: 12,
          published_at: "2025-03-01T12:00:00+00:00",
          headline: "Hotfix #31 Now Live!",
          body: "[list][*]Old notes.[/list]"
        )
      ]
    }

    <<~HTML
      <html>
        <body>
          <div id="application_config" data-initialEvents="#{CGI.escapeHTML(payload.to_json)}"></div>
        </body>
      </html>
    HTML
  end

  def event_payload(gid:, event_type:, published_at:, headline:, body:)
    {
      "gid" => gid,
      "event_type" => event_type,
      "rtime32_start_time" => Time.zone.parse(published_at).to_i,
      "announcement_body" => {
        "headline" => headline,
        "body" => body,
        "posttime" => Time.zone.parse(published_at).to_i
      }
    }
  end
end
