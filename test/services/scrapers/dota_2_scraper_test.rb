require "test_helper"
require "cgi"

class Scrapers::Dota2ScraperTest < ActiveSupport::TestCase
  test "collects official dota 2 patch updates from steam news data" do
    travel_to Time.zone.local(2026, 3, 16, 12, 0, 0) do
      scraper = Scrapers::Dota2Scraper.new
      html = index_html
      scraper.define_singleton_method(:fetch_document) do |_url|
        Nokogiri::HTML(html)
      end

      results = scraper.call

      assert_equal 6, results.size

      latest_patch = results.first
      assert_equal "Dota 2 Update - 1/30/2026", latest_patch[:title]
      assert_equal "https://store.steampowered.com/news/app/570/view/533247947228316765", latest_patch[:source_url]
      assert_equal Time.zone.parse("2026-01-30T18:32:00+00:00").to_i, latest_patch[:published_at].to_i
      assert_includes latest_patch[:content], "Clinkz's Skeleton Archers"

      patch_740c = results.second
      assert_equal "7.40c Gameplay Patch", patch_740c[:title]
      assert_equal Time.zone.parse("2026-01-21T19:43:00+00:00").to_i, patch_740c[:published_at].to_i
      assert_includes patch_740c[:content], "https://www.dota2.com/patches/7.40c"
      assert_includes patch_740c[:content], "Monster Hunter event ends February 6, 2026"

      patch_740b = results.third
      assert_equal "7.40b Gameplay Patch", patch_740b[:title]
      assert_equal Time.zone.parse("2025-12-23T18:25:00+00:00").to_i, patch_740b[:published_at].to_i
      assert_includes patch_740b[:content], "Dota+ Talent Pickrates and Winrates"

      major_patch = results.fourth
      assert_equal "Introducing Largo and Patch 7.40", major_patch[:title]
      assert_equal Time.zone.parse("2025-12-15T19:27:00+00:00").to_i, major_patch[:published_at].to_i
      assert_includes major_patch[:content], "Introducing Dota's newest hero: Largo"

      october_update = results.fifth
      assert_equal "Dota 2 Update - 10/09/2025", october_update[:title]
      assert_equal Time.zone.parse("2025-10-09T18:18:00+00:00").to_i, october_update[:published_at].to_i
      assert_includes october_update[:content], "Helm of the Dominator"

      patch_739e = results[5]
      assert_equal "7.39e Gameplay Patch", patch_739e[:title]
      assert_equal Time.zone.parse("2025-10-02T18:24:00+00:00").to_i, patch_739e[:published_at].to_i
      assert_includes patch_739e[:content], "https://www.dota2.com/patches/7.39e"
    end
  end

  private

  def index_html
    update_jan_time = Time.zone.parse("2026-01-30T18:32:00+00:00").to_i
    patch_740c_time = Time.zone.parse("2026-01-21T19:43:00+00:00").to_i
    patch_740b_time = Time.zone.parse("2025-12-23T18:25:00+00:00").to_i
    patch_740_time = Time.zone.parse("2025-12-15T19:27:00+00:00").to_i
    update_oct_time = Time.zone.parse("2025-10-09T18:18:00+00:00").to_i
    patch_739e_time = Time.zone.parse("2025-10-02T18:24:00+00:00").to_i
    stale_time = Time.zone.parse("2025-08-28T18:32:00+00:00").to_i

    payload = {
      "documents" => [
        { "unique_id" => "533247947228316765", "event_type" => 12, "start_time" => update_jan_time },
        { "unique_id" => "537750912402194535", "event_type" => 12, "start_time" => patch_740c_time },
        { "unique_id" => "517481543704249946", "event_type" => 12, "start_time" => patch_740b_time },
        { "unique_id" => "533243594419470467", "event_type" => 14, "start_time" => patch_740_time },
        { "unique_id" => "530985997248233579", "event_type" => 12, "start_time" => update_oct_time },
        { "unique_id" => "536611069461790877", "event_type" => 12, "start_time" => patch_739e_time },
        { "unique_id" => "536611691635409378", "event_type" => 12, "start_time" => stale_time }
      ],
      "events" => [
        event_payload(
          gid: "533247947228316765",
          event_type: 12,
          published_at: "2026-01-30T18:32:00+00:00",
          headline: "Dota 2 Update - 1/30/2026",
          body: <<~BODY
            [p]Over the past few days we've addressed the following issues:[/p]
            [list]
            [*][p]Fixed a bug where Clinkz's Skeleton Archers were doing more than the intended amount of damage to buildings.[/p][/*]
            [*][p]Fixed a bug where Slark's Depth Shroud was not applying the intended move speed and health regen to allies.[/p][/*]
            [/list]
          BODY
        ),
        event_payload(
          gid: "537750912402194535",
          event_type: 12,
          published_at: "2026-01-21T19:43:00+00:00",
          headline: "7.40c Gameplay Patch",
          body: <<~BODY
            [p]Patch 7.40c is out now and you can check out the patch notes [url="https://www.dota2.com/patches/7.40c"]here[/url].[/p]
            [p]As a reminder, the Monster Hunter event ends February 6, 2026.[/p]
          BODY
        ),
        event_payload(
          gid: "517481543704249946",
          event_type: 12,
          published_at: "2025-12-23T18:25:00+00:00",
          headline: "7.40b Gameplay Patch",
          body: <<~BODY
            [p]Patch 7.40b is out now and you can check out the patch notes [url="https://www.dota2.com/patches/7.40b"]here[/url].[/p]
            [list]
            [*][p]Fixed Dota+ Talent Pickrates and Winrates not properly aggregating[/p][/*]
            [/list]
          BODY
        ),
        event_payload(
          gid: "533243594419470467",
          event_type: 14,
          published_at: "2025-12-15T19:27:00+00:00",
          headline: "Introducing Largo and Patch 7.40",
          body: <<~BODY
            [p]Introducing Dota's newest hero: Largo, the bard.[/p]
            [p]Patch 7.40 also ships alongside him.[/p]
          BODY
        ),
        event_payload(
          gid: "530985997248233579",
          event_type: 12,
          published_at: "2025-10-09T18:18:00+00:00",
          headline: "Dota 2 Update - 10/09/2025",
          body: <<~BODY
            [p]Since the 7.39e gameplay patch, we've addressed the following issues:[/p]
            [list]
            [*][p]Fixed server crash involving Helm of the Dominator[/p][/*]
            [/list]
          BODY
        ),
        event_payload(
          gid: "536611069461790877",
          event_type: 12,
          published_at: "2025-10-02T18:24:00+00:00",
          headline: "7.39e Gameplay Patch",
          body: <<~BODY
            [p]Patch 7.39e is out now and you can check out the patch notes [url="https://www.dota2.com/patches/7.39e"]here[/url].[/p]
          BODY
        ),
        event_payload(
          gid: "536611691635409378",
          event_type: 12,
          published_at: "2025-08-28T18:32:00+00:00",
          headline: "7.39d Gameplay Patch",
          body: "[p]Older notes.[/p]"
        ),
        event_payload(
          gid: "530985917539680600",
          event_type: 13,
          published_at: "2025-10-07T18:02:00+00:00",
          headline: "Collector's Cache Voting Open Now",
          body: "[p]Cosmetic voting post.[/p]"
        )
      ]
    }

    <<~HTML
      <html>
        <body>
          <div id="application_config" data-initialevents="#{CGI.escapeHTML(payload.to_json)}"></div>
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
