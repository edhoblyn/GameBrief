require "test_helper"
require "cgi"

class Scrapers::Ff7RebirthScraperTest < ActiveSupport::TestCase
  test "collects official FF7 Rebirth version updates from steam news" do
    travel_to Time.zone.local(2026, 3, 16, 12, 0, 0) do
      scraper = Scrapers::Ff7RebirthScraper.new
      documents_by_url = pages

      scraper.define_singleton_method(:fetch_document) do |url|
        Nokogiri::HTML(documents_by_url.fetch(url))
      end

      results = scraper.call

      assert_equal 2, results.size

      v1004 = results.first
      assert_equal "Version 1.004 Release Notice", v1004[:title]
      assert_equal "https://store.steampowered.com/news/app/2909400/view/514098767258978258", v1004[:source_url]
      assert_equal Time.zone.at(1762274621).to_i, v1004[:published_at].to_i
      assert_includes v1004[:content], "Added DLSS Multi Frame Generation support"

      v1003 = results.second
      assert_equal "Version 1.003 Release Notice", v1003[:title]
      assert_includes v1003[:content], "Frame generation compatibility"
    end
  end

  test "excludes non-update event types and stale entries" do
    travel_to Time.zone.local(2026, 3, 16, 12, 0, 0) do
      scraper = Scrapers::Ff7RebirthScraper.new
      documents_by_url = pages

      scraper.define_singleton_method(:fetch_document) do |url|
        Nokogiri::HTML(documents_by_url.fetch(url))
      end

      results = scraper.call

      titles = results.map { |r| r[:title] }
      assert_not_includes titles, "We have been nominated for a Steam Award!"
      assert_not_includes titles, "Version 1.000 Release Notice"
    end
  end

  private

  def pages
    v1004_time   = 1762274621
    v1003_time   = Time.zone.parse("2025-03-06T14:00:00+00:00").to_i
    award_time   = Time.zone.parse("2025-12-18T12:00:00+00:00").to_i
    stale_time   = Time.zone.parse("2023-12-01T12:00:00+00:00").to_i

    index_payload = {
      "documents" => [
        { "unique_id" => "514098767258978258", "event_type" => 12, "start_time" => v1004_time },
        { "unique_id" => "527588008025654786", "event_type" => 12, "start_time" => v1003_time },
        { "unique_id" => "498339977282717253", "event_type" => 28, "start_time" => award_time },
        { "unique_id" => "999999999999999999", "event_type" => 12, "start_time" => stale_time }
      ]
    }

    index_html = <<~HTML
      <html>
        <body>
          <div id="application_config" data-initialevents="#{CGI.escapeHTML(index_payload.to_json)}"></div>
        </body>
      </html>
    HTML

    v1004_payload = [
      {
        "gid" => "514098767258978258",
        "announcement_body" => {
          "headline" => "Version 1.004 Release Notice",
          "body" => "[list]\n[*]  Added DLSS Multi Frame Generation support.\n[/list]",
          "posttime" => v1004_time
        }
      }
    ]

    v1003_payload = [
      {
        "gid" => "527588008025654786",
        "announcement_body" => {
          "headline" => "Version 1.003 Release Notice",
          "body" => "[list]\n[*]  Frame generation compatibility improvements.\n[/list]",
          "posttime" => v1003_time
        }
      }
    ]

    detail_html = ->(payload) {
      <<~HTML
        <html>
          <body>
            <div id="application_config" data-partnereventstore="#{CGI.escapeHTML(payload.to_json)}"></div>
          </body>
        </html>
      HTML
    }

    {
      "https://store.steampowered.com/news/app/2909400?updates=true" => index_html,
      "https://store.steampowered.com/news/app/2909400/view/514098767258978258" => detail_html.call(v1004_payload),
      "https://store.steampowered.com/news/app/2909400/view/527588008025654786" => detail_html.call(v1003_payload)
    }
  end
end
