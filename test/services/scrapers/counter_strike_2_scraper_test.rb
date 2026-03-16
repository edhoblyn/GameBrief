require "test_helper"

class Scrapers::CounterStrike2ScraperTest < ActiveSupport::TestCase
  test "collects recent counter-strike 2 updates from valve's official steam news data" do
    travel_to Time.zone.local(2026, 3, 16, 12, 0, 0) do
      scraper = Scrapers::CounterStrike2Scraper.new
      documents = {
        Scrapers::CounterStrike2Scraper::INDEX_URL => Nokogiri::HTML(index_html),
        "https://store.steampowered.com/news/app/730/view/518615049848225874" => Nokogiri::HTML(detail_html(
          published_at: "2026-03-11T23:00:06+00:00",
          canonical_url: "https://store.steampowered.com/news/app/730/view/518615049848225874",
          headline: "Counter-Strike 2 Update",
          body: "[ MAPS ]\n[list]\n[*] Fixed a pixel gap on Dust II.\n[*] Updated Alpine from the Community Workshop ([url=https://example.com/alpine]Update Notes[/url])\n[/list]"
        )),
        "https://store.steampowered.com/news/app/730/view/502851820603834533" => Nokogiri::HTML(detail_html(
          published_at: "2026-03-04T22:51:40+00:00",
          canonical_url: "https://store.steampowered.com/news/app/730/view/502851820603834533",
          headline: "Counter-Strike 2 Update",
          body: "[ MISC ]\n[list]\n[*] Added item listing changes.\n[/list]"
        ))
      }

      scraper.define_singleton_method(:fetch_document) do |url|
        documents.fetch(url)
      end

      results = scraper.call

      assert_equal 2, results.size

      latest_update = results.first
      assert_equal "Counter-Strike 2 Update", latest_update[:title]
      assert_equal "https://store.steampowered.com/news/app/730/view/518615049848225874", latest_update[:source_url]
      assert_equal Time.zone.parse("2026-03-11T23:00:06+00:00").to_i, latest_update[:published_at].to_i
      assert_includes latest_update[:content], "[ MAPS ]"
      assert_includes latest_update[:content], "- Fixed a pixel gap on Dust II."
      assert_includes latest_update[:content], "Update Notes (https://example.com/alpine)"

      previous_update = results.second
      assert_equal Time.zone.parse("2026-03-04T22:51:40+00:00").to_i, previous_update[:published_at].to_i
      assert_includes previous_update[:content], "- Added item listing changes."
    end
  end

  private

  def index_html
    recent_update_time = Time.zone.local(2026, 3, 11, 23, 0, 6).to_i
    second_update_time = Time.zone.local(2026, 3, 4, 22, 51, 40).to_i
    old_update_time = Time.zone.local(2025, 8, 15, 12, 0, 0).to_i

    payload = {
      "documents" => [
        { "unique_id" => "518615049848225874", "event_type" => 12, "start_time" => recent_update_time },
        { "unique_id" => "502851820603834533", "event_type" => 12, "start_time" => second_update_time },
        { "unique_id" => "518615049848225858", "event_type" => 13, "start_time" => recent_update_time },
        { "unique_id" => "111111111111111111", "event_type" => 12, "start_time" => old_update_time }
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

  def detail_html(published_at:, canonical_url:, headline:, body:)
    event_payload = [
      {
        "announcement_body" => {
          "headline" => headline,
          "body" => body,
          "posttime" => Time.zone.parse(published_at).to_i
        }
      }
    ]

    <<~HTML
      <html>
        <head>
          <meta property="article:published_time" content="#{published_at}">
          <link rel="canonical" href="#{canonical_url}">
        </head>
        <body>
          <div id="application_config" data-partnereventstore='#{event_payload.to_json}'></div>
        </body>
      </html>
    HTML
  end
end
