require "test_helper"

class Scrapers::LeagueOfLegendsScraperTest < ActiveSupport::TestCase
  test "collects recent patch notes and ignores entries older than six months" do
    travel_to Time.zone.local(2026, 3, 16, 12, 0, 0) do
      scraper = Scrapers::LeagueOfLegendsScraper.new
      documents = {
        Scrapers::LeagueOfLegendsScraper::INDEX_URL => Nokogiri::HTML(index_html),
        "https://www.leagueoflegends.com/en-us/news/game-updates/league-of-legends-patch-26-5-notes" => Nokogiri::HTML(detail_html("League of Legends Patch 26.5 Notes", "2026-03-03T19:00:00.000Z", "Champion Buffs")),
        "https://www.leagueoflegends.com/en-us/news/game-updates/patch-26-4-notes" => Nokogiri::HTML(detail_html("Patch 26.4 Notes", "2026-02-18T19:00:00.000Z", "System Updates"))
      }

      scraper.define_singleton_method(:fetch_document) do |url|
        documents.fetch(url)
      end

      results = scraper.call

      assert_equal 2, results.size

      latest_patch = results.first
      assert_equal "League of Legends Patch 26.5 Notes", latest_patch[:title]
      assert_equal "https://www.leagueoflegends.com/en-us/news/game-updates/league-of-legends-patch-26-5-notes", latest_patch[:source_url]
      assert_equal Time.zone.parse("2026-03-03T19:00:00.000Z").to_i, latest_patch[:published_at].to_i
      assert_includes latest_patch[:content], "Champion Buffs"
      assert_includes latest_patch[:content], "- Base health increased"

      previous_patch = results.second
      assert_equal "Patch 26.4 Notes", previous_patch[:title]
      assert_equal Time.zone.parse("2026-02-18T19:00:00.000Z").to_i, previous_patch[:published_at].to_i
      assert_includes previous_patch[:content], "System Updates"
    end
  end

  private

  def index_html
    <<~HTML
      <html>
        <body>
          <section data-testid="article-card-grid">
            <a data-testid="articlefeaturedcard-component" href="/en-us/news/game-updates/league-of-legends-patch-26-5-notes" aria-label="League of Legends Patch 26.5 Notes">
              <div data-testid="card-title">League of Legends Patch 26.5 Notes</div>
              <time datetime="2026-03-03T19:00:00.000Z">2026-03-03T19:00:00.000Z</time>
            </a>
            <a data-testid="articlefeaturedcard-component" href="/en-us/news/game-updates/patch-26-4-notes" aria-label="Patch 26.4 Notes">
              <div data-testid="card-title">Patch 26.4 Notes</div>
              <time datetime="2026-02-18T19:00:00.000Z">2026-02-18T19:00:00.000Z</time>
            </a>
            <a data-testid="articlefeaturedcard-component" href="/en-us/news/game-updates/patch-25-15-notes" aria-label="Patch 25.15 Notes">
              <div data-testid="card-title">Patch 25.15 Notes</div>
              <time datetime="2025-08-01T18:00:00.000Z">2025-08-01T18:00:00.000Z</time>
            </a>
          </section>
        </body>
      </html>
    HTML
  end

  def detail_html(title, published_at, section_heading)
    <<~HTML
      <html>
        <body>
          <main>
            <section data-testid="blade">
              <h1 data-testid="title">#{title}</h1>
              <time datetime="#{published_at}">#{published_at}</time>
              <div data-testid="rich-text-html">
                <div>Short teaser copy.</div>
              </div>
            </section>
            <section data-testid="RichTextPatchNotesBlade">
              <div data-testid="rich-text-html">
                <div>
                  <h2>#{section_heading}</h2>
                  <p>Patch summary.</p>
                  <ul>
                    <li>Base health increased</li>
                    <li>Cooldown reduced</li>
                  </ul>
                </div>
              </div>
            </section>
          </main>
        </body>
      </html>
    HTML
  end
end
