require "test_helper"

class Scrapers::CallOfDutyBlackOps7ScraperTest < ActiveSupport::TestCase
  test "collects Black Ops 7 patch notes from the call of duty patch notes index" do
    scraper = Scrapers::CallOfDutyBlackOps7Scraper.new
    documents = {
      Scrapers::CallOfDutyBlackOps7Scraper::INDEX_URL => Nokogiri::HTML(index_html),
      "https://www.callofduty.com/patchnotes/2026/03/black-ops-7-season-2-update" => Nokogiri::HTML(article_html(
        title: "Black Ops 7 Season 2 Update",
        published_at: "2026-03-10T17:00:00Z",
        body: "<p>Season 2 introduces new multiplayer maps and weapon balancing.</p>"
      )),
      "https://www.callofduty.com/patchnotes/2026/02/black-ops-7-mid-season-patch" => Nokogiri::HTML(article_html(
        title: "Black Ops 7 Mid-Season Balance Patch",
        published_at: "2026-02-14T17:00:00Z",
        body: "<p>Shotgun damage reduced. SMG movement speed increased.</p>"
      ))
    }

    scraper.define_singleton_method(:fetch_document) do |url|
      documents.fetch(url)
    end

    results = scraper.call

    assert_equal 2, results.size

    first = results.first
    assert_equal "Black Ops 7 Season 2 Update", first[:title]
    assert_equal "https://www.callofduty.com/patchnotes/2026/03/black-ops-7-season-2-update", first[:source_url]
    assert_equal Time.zone.parse("2026-03-10T17:00:00Z"), first[:published_at]
    assert_includes first[:content], "Season 2 introduces new multiplayer maps"

    second = results.second
    assert_equal "https://www.callofduty.com/patchnotes/2026/02/black-ops-7-mid-season-patch", second[:source_url]
    assert_equal Time.zone.parse("2026-02-14T17:00:00Z"), second[:published_at]
  end

  test "skips links that do not mention black ops" do
    scraper = Scrapers::CallOfDutyBlackOps7Scraper.new
    documents = {
      Scrapers::CallOfDutyBlackOps7Scraper::INDEX_URL => Nokogiri::HTML(index_with_unrelated_links_html)
    }

    scraper.define_singleton_method(:fetch_document) do |url|
      documents.fetch(url)
    end

    results = scraper.call

    assert_equal 0, results.size
  end

  private

  def index_html
    <<~HTML
      <html>
        <body>
          <a href="/patchnotes/2026/03/black-ops-7-season-2-update">Black Ops 7 Season 2 Update</a>
          <a href="/patchnotes/2026/02/black-ops-7-mid-season-patch">Black Ops 7 Mid-Season Balance Patch</a>
        </body>
      </html>
    HTML
  end

  def index_with_unrelated_links_html
    <<~HTML
      <html>
        <body>
          <a href="/patchnotes/2026/03/warzone-update">Warzone Season 3 Update</a>
        </body>
      </html>
    HTML
  end

  def article_html(title:, published_at:, body:)
    <<~HTML
      <html>
        <head>
          <meta property="article:published_time" content="#{published_at}">
        </head>
        <body>
          <main>
            <h1>#{title}</h1>
            #{body}
          </main>
        </body>
      </html>
    HTML
  end
end
