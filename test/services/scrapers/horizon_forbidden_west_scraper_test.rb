require "test_helper"

class Scrapers::HorizonForbiddenWestScraperTest < ActiveSupport::TestCase
  test "collects official horizon forbidden west pc patch notes from steam news data" do
    travel_to Time.zone.local(2026, 3, 16, 12, 0, 0) do
      scraper = Scrapers::HorizonForbiddenWestScraper.new
      html = index_html
      scraper.define_singleton_method(:fetch_document) do |_url|
        Nokogiri::HTML(html)
      end

      results = scraper.call

      assert_equal 3, results.size

      latest_update = results.first
      assert_equal "AMD FSR 3.1 is now available in Horizon Forbidden West Complete Edition", latest_update[:title]
      assert_equal "https://store.steampowered.com/news/app/2420110/view/4229524700808157679", latest_update[:source_url]
      assert_equal Time.zone.parse("2024-06-27T13:38:00+00:00").to_i, latest_update[:published_at].to_i
      assert_includes latest_update[:content], "Release Notes"
      assert_includes latest_update[:content], "- Added AMD FSR 3.1 with frame generation and Native AA options."
      assert_includes latest_update[:content], "- Various user interface fixes."

      hotfix_update = results.second
      assert_equal "Horizon Forbidden West Complete Edition Hotfix 1.3.57.0", hotfix_update[:title]
      assert_equal Time.zone.parse("2024-04-25T12:23:00+00:00").to_i, hotfix_update[:published_at].to_i
      assert_includes hotfix_update[:content], "- Stability improvements."

      old_update = results.third
      assert_equal "Horizon Forbidden West Complete Edition 1.0.43.0 Release Notes", old_update[:title]
      assert_equal Time.zone.parse("2024-03-28T18:07:00+00:00").to_i, old_update[:published_at].to_i
      assert_includes old_update[:content], "- Various crash fixes and stability improvements."
    end
  end

  private

  def index_html
    relevant_update_time = Time.zone.parse("2024-06-27T13:38:00+00:00").to_i
    hotfix_time = Time.zone.parse("2024-04-25T12:23:00+00:00").to_i
    old_update_time = Time.zone.parse("2024-03-28T18:07:00+00:00").to_i
    stale_update_time = Time.zone.parse("2022-03-20T09:00:00+00:00").to_i

    payload = {
      "documents" => [
        { "unique_id" => "4229524700808157679", "event_type" => 13, "start_time" => relevant_update_time },
        { "unique_id" => "4172098098015834680", "event_type" => 12, "start_time" => hotfix_time },
        { "unique_id" => "4174347361773487031", "event_type" => 13, "start_time" => old_update_time },
        { "unique_id" => "111111111111111111", "event_type" => 13, "start_time" => stale_update_time }
      ],
      "events" => [
        event_payload(
          gid: "4229524700808157679",
          event_type: 13,
          published_at: "2024-06-27T13:38:00+00:00",
          headline: "AMD FSR 3.1 is now available in Horizon Forbidden West Complete Edition",
          body: <<~BODY
            Hey everyone,

            [h3]Release Notes[/h3]
            [list]
            [*]Added AMD FSR 3.1 with frame generation and Native AA options.
            [*]Various user interface fixes.
            [/list]
          BODY
        ),
        event_payload(
          gid: "4172098098015834680",
          event_type: 12,
          published_at: "2024-04-25T12:23:00+00:00",
          headline: "Horizon Forbidden West Complete Edition Hotfix 1.3.57.0",
          body: <<~BODY
            Hey everyone,

            [h3]Release Notes[/h3]
            [list]
            [*]Stability improvements.
            [/list]
          BODY
        ),
        event_payload(
          gid: "4174347361773487031",
          event_type: 13,
          published_at: "2024-03-28T18:07:00+00:00",
          headline: "Horizon Forbidden West Complete Edition 1.0.43.0 Release Notes",
          body: <<~BODY
            Hey everyone,

            [h3]Release Notes[/h3]
            [list]
            [*]Various crash fixes and stability improvements.
            [/list]
          BODY
        ),
        event_payload(
          gid: "111111111111111111",
          event_type: 13,
          published_at: "2022-03-20T09:00:00+00:00",
          headline: "Horizon Forbidden West Complete Edition 0.9.0.0 Release Notes",
          body: "[list][*]Old notes.[/list]"
        ),
        event_payload(
          gid: "222222222222222222",
          event_type: 20,
          published_at: "2025-12-19T10:00:00+00:00",
          headline: "Save 40% on Horizon Forbidden West Complete Edition!",
          body: "[list][*]Sale copy.[/list]"
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
