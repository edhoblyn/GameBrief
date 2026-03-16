require "test_helper"

class Scrapers::Cyberpunk2077ScraperTest < ActiveSupport::TestCase
  test "collects official cyberpunk 2077 patch updates from steam news data" do
    travel_to Time.zone.local(2026, 3, 16, 12, 0, 0) do
      scraper = Scrapers::Cyberpunk2077Scraper.new
      html = index_html
      scraper.define_singleton_method(:fetch_document) do |_url|
        Nokogiri::HTML(html)
      end

      results = scraper.call

      assert_equal 4, results.size

      latest_patch = results.first
      assert_equal "Patch 2.31", latest_patch[:title]
      assert_equal "https://store.steampowered.com/news/app/1091500/view/503961862016073928", latest_patch[:source_url]
      assert_equal Time.zone.parse("2025-09-11T16:00:00+00:00").to_i, latest_patch[:published_at].to_i
      assert_includes latest_patch[:content], "Vehicles"
      assert_includes latest_patch[:content], "- Updated AutoDrive."

      update_23 = results.second
      assert_equal "Update 2.3 Patch Notes", update_23[:title]
      assert_equal Time.zone.parse("2025-07-16T15:00:00+00:00").to_i, update_23[:published_at].to_i
      assert_includes update_23[:content], "- Added 4 new vehicles, including several Side Jobs tied to acquiring them:"

      patch_221 = results.third
      assert_equal "Patch 2.21", patch_221[:title]
      assert_equal Time.zone.parse("2025-01-23T16:00:00+00:00").to_i, patch_221[:published_at].to_i
      assert_includes patch_221[:content], "Photo Mode"
      assert_includes patch_221[:content], "- Characters will now be properly saved in presets."

      update_22 = results.fourth
      assert_equal "Update 2.2 is live!", update_22[:title]
      assert_equal Time.zone.parse("2024-12-10T16:00:00+00:00").to_i, update_22[:published_at].to_i
      assert_includes update_22[:content], "New Features"
      assert_includes update_22[:content], "CrystalCoat is now compatible with select vehicle brands."
    end
  end

  private

  def index_html
    latest_time = Time.zone.parse("2025-09-11T16:00:00+00:00").to_i
    update_23_time = Time.zone.parse("2025-07-16T15:00:00+00:00").to_i
    patch_221_time = Time.zone.parse("2025-01-23T16:00:00+00:00").to_i
    stale_time = Time.zone.parse("2023-12-04T16:00:00+00:00").to_i

    payload = {
      "documents" => [
        { "unique_id" => "503961862016073928", "event_type" => 13, "start_time" => latest_time },
        { "unique_id" => "510711823303967305", "event_type" => 14, "start_time" => update_23_time },
        { "unique_id" => "538843836072329454", "event_type" => 13, "start_time" => patch_221_time },
        { "unique_id" => "3873721309645503927", "event_type" => 12, "start_time" => stale_time }
      ],
      "events" => [
        event_payload(
          gid: "503961862016073928",
          event_type: 13,
          published_at: "2025-09-11T16:00:00+00:00",
          headline: "Patch 2.31",
          body: <<~BODY
            [p]Patch 2.31 for Cyberpunk 2077 is now live![/p]
            [h3]Vehicles[/h3]
            [list]
            [*][p]Updated AutoDrive.[/p][/*]
            [*][p]Fixed an issue where Johnny always spawned in the passenger seat when using the Delamain Cab service.[/p][/*]
            [/list]
          BODY
        ),
        event_payload(
          gid: "510711823303967305",
          event_type: 14,
          published_at: "2025-07-16T15:00:00+00:00",
          headline: "Update 2.3 Patch Notes",
          body: <<~BODY
            [p]Update 2.3 lands tomorrow![/p]
            [h1][b]Vehicles[/b][/h1]
            [list]
            [*][p]Added 4 new vehicles, including several Side Jobs tied to acquiring them:[/p][/*]
            [/list]
          BODY
        ),
        event_payload(
          gid: "538843836072329454",
          event_type: 13,
          published_at: "2025-01-23T16:00:00+00:00",
          headline: "Patch 2.21",
          body: <<~BODY
            [h2]Photo Mode[/h2]
            [list]
            [*]Characters will now be properly saved in presets.
            [*]Spawned characters will now be visible after adding a background.
            [/list]
          BODY
        ),
        event_payload(
          gid: "514069779412157218",
          event_type: 13,
          published_at: "2024-12-10T16:00:00+00:00",
          headline: "Update 2.2 is live!",
          body: "[h2]New Features[/h2][list][*]CrystalCoat is now compatible with select vehicle brands.[/list]"
        ),
        event_payload(
          gid: "3873721309645503927",
          event_type: 12,
          published_at: "2023-12-04T16:00:00+00:00",
          headline: "Update 2.1 Patch Notes",
          body: "[list][*]Old notes.[/list]"
        ),
        event_payload(
          gid: "999999999999999999",
          event_type: 28,
          published_at: "2025-12-10T10:00:00+00:00",
          headline: "5th Anniversary Trailer — City of Legends",
          body: "[p]Promo copy.[/p]"
        )
      ]
    }

    <<~HTML
      <html>
        <body>
          <div id="application_config" data-initialEvents='#{payload.to_json}'></div>
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
