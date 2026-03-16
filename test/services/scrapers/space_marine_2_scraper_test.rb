require "test_helper"

class Scrapers::SpaceMarine2ScraperTest < ActiveSupport::TestCase
  test "collects recent official space marine 2 patch updates from focus community pages" do
    travel_to Time.zone.local(2026, 3, 16, 12, 0, 0) do
      scraper = Scrapers::SpaceMarine2Scraper.new
      documents = {
        "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs" => Nokogiri::HTML(index_page_one_html),
        "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs?page=2" => Nokogiri::HTML(index_page_two_html),
        "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs?page=3" => Nokogiri::HTML(index_page_three_html),
        "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/360-hotfix-12-1-patch-notes" => Nokogiri::HTML(detail_html(
          title: "Hotfix 12.1 Patch Notes",
          source_url: "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/360-hotfix-12-1-patch-notes",
          published_at: "2026-03-05T10:04:30Z",
          content: <<~HTML
            <h2>GENERAL FIXES</h2>
            <ul>
              <li>Crash fixes.</li>
              <li>Fixed an issue that was blocking progress on Disruption.</li>
            </ul>
          HTML
        )),
        "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/356-patch-notes-12-0" => Nokogiri::HTML(detail_html(
          title: "Patch Notes 12.0",
          source_url: "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/356-patch-notes-12-0",
          published_at: "2026-02-26T10:02:53Z",
          content: <<~HTML
            <h2>GAMEPLAY AND BALANCING TWEAKS</h2>
            <h3>Techmarine</h3>
            <ul>
              <li>Added the Techmarine class.</li>
              <li>Added the Omnissian Axe.</li>
            </ul>
          HTML
        )),
        "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/312-the-reclamation-update-is-live" => Nokogiri::HTML(detail_html(
          title: "Space Marine 2's Reclamation Update is LIVE.",
          source_url: "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/312-the-reclamation-update-is-live",
          published_at: "2025-12-10T15:00:00Z",
          content: <<~HTML
            <h2>NEW CONTENT</h2>
            <ul>
              <li>Added the Reclamation update.</li>
              <li>Introduced a new operation.</li>
            </ul>
          HTML
        )),
        "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/296-patch-notes-11-0" => Nokogiri::HTML(detail_html(
          title: "Patch Notes 11.0",
          source_url: "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/296-patch-notes-11-0",
          published_at: "2025-10-29T14:20:00Z",
          content: <<~HTML
            <h2>LEVELS</h2>
            <ul>
              <li>Lots of minor fixes with level geometry.</li>
            </ul>
          HTML
        )),
        "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/250-patch-notes-10-0" => Nokogiri::HTML(detail_html(
          title: "Patch Notes 10.0",
          source_url: "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/250-patch-notes-10-0",
          published_at: "2025-09-04T09:00:00Z",
          content: <<~HTML
            <h2>OLDER NOTES</h2>
            <ul>
              <li>Too old for the six month import window.</li>
            </ul>
          HTML
        ))
      }

      scraper.define_singleton_method(:fetch_document) do |url|
        documents.fetch(url)
      end

      results = scraper.call

      assert_equal 4, results.size

      latest_patch = results.first
      assert_equal "Hotfix 12.1 Patch Notes", latest_patch[:title]
      assert_equal "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/360-hotfix-12-1-patch-notes", latest_patch[:source_url]
      assert_equal Time.zone.parse("2026-03-05T10:04:30Z").to_i, latest_patch[:published_at].to_i
      assert_includes latest_patch[:content], "GENERAL FIXES"
      assert_includes latest_patch[:content], "- Crash fixes."

      second_patch = results.second
      assert_equal "Patch Notes 12.0", second_patch[:title]
      assert_includes second_patch[:content], "GAMEPLAY AND BALANCING TWEAKS"
      assert_includes second_patch[:content], "Techmarine"

      third_patch = results.third
      assert_equal "Space Marine 2's Reclamation Update is LIVE.", third_patch[:title]
      assert_includes third_patch[:content], "- Added the Reclamation update."

      fourth_patch = results.fourth
      assert_equal "Patch Notes 11.0", fourth_patch[:title]
      assert_equal Time.zone.parse("2025-10-29T14:20:00Z").to_i, fourth_patch[:published_at].to_i
    end
  end

  private

  def index_page_one_html
    index_html(
      max_page: 3,
      cards: [
        {
          title: "Hotfix 12.1 Patch Notes",
          href: "/focus-entertainment/space-marine-2/blogs/360-hotfix-12-1-patch-notes",
          since: "1 week ago"
        },
        {
          title: "Patch Notes 12.0",
          href: "/focus-entertainment/space-marine-2/blogs/356-patch-notes-12-0",
          since: "2 weeks ago"
        },
        {
          title: "Collector's Editions Giveaway!",
          href: "/focus-entertainment/space-marine-2/blogs/350-collector-s-editions-giveaway",
          since: "3 weeks ago"
        }
      ]
    )
  end

  def index_page_two_html
    index_html(
      max_page: 3,
      cards: [
        {
          title: "Space Marine 2's Reclamation Update is LIVE.",
          href: "/focus-entertainment/space-marine-2/blogs/312-the-reclamation-update-is-live",
          since: "3 months ago"
        },
        {
          title: "Patch Notes 11.0",
          href: "/focus-entertainment/space-marine-2/blogs/296-patch-notes-11-0",
          since: "4 months ago"
        }
      ]
    )
  end

  def index_page_three_html
    index_html(
      max_page: 3,
      cards: [
        {
          title: "Patch Notes 10.0",
          href: "/focus-entertainment/space-marine-2/blogs/250-patch-notes-10-0",
          since: "6 months ago"
        }
      ]
    )
  end

  def index_html(max_page:, cards:)
    pager_links = (1..max_page).map do |page|
      %(<a class="button" href="/focus-entertainment/space-marine-2/blogs?page=#{page}">#{page}</a>)
    end.join

    cards_html = cards.map do |card|
      <<~HTML
        <div class="devblog-showroom-item">
          <div class="info-hover">
            <span class="since-when">#{card[:since]}</span>
          </div>
          <div class="devblog-showroom-item-more">
            <a class="devblog-showroom-item-more-link" href="#{card[:href]}">READ MORE</a>
          </div>
          <h3 class="title-article">#{card[:title]}</h3>
        </div>
      HTML
    end.join

    <<~HTML
      <html>
        <body>
          #{cards_html}
          <div class="pager-buttons">
            #{pager_links}
          </div>
        </body>
      </html>
    HTML
  end

  def detail_html(title:, source_url:, published_at:, content:)
    payload = {
      "blogpost" => {
        "Title" => title,
        "Content" => content,
        "RootUrl" => URI(source_url).path,
        "DatePublication" => published_at
      }
    }

    <<~HTML
      <html>
        <head>
          <meta property="og:url" content="#{source_url}">
          <meta property="article:published_time" content="#{published_at}">
        </head>
        <body>
          <script id="ng-state" type="application/json">#{payload.to_json}</script>
        </body>
      </html>
    HTML
  end
end
