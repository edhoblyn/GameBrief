require "test_helper"

class Scrapers::PokemonPokopiaScraperTest < ActiveSupport::TestCase
  test "collects curated official Pokémon Pokopia updates" do
    scraper = Scrapers::PokemonPokopiaScraper.new
    documents = {
      Scrapers::PokemonPokopiaScraper::PRESS_RELEASE_URL => Nokogiri::HTML(press_release_html),
      Scrapers::PokemonPokopiaScraper::NINTENDO_NEWS_URL => Nokogiri::HTML(nintendo_news_html),
      Scrapers::PokemonPokopiaScraper::MICROSITE_URL => Nokogiri::HTML(home_html),
      "#{Scrapers::PokemonPokopiaScraper::MICROSITE_URL}explore/" => Nokogiri::HTML(explore_html),
      "#{Scrapers::PokemonPokopiaScraper::MICROSITE_URL}create/" => Nokogiri::HTML(create_html),
      "#{Scrapers::PokemonPokopiaScraper::MICROSITE_URL}discover/" => Nokogiri::HTML(discover_html),
      "#{Scrapers::PokemonPokopiaScraper::MICROSITE_URL}buy-now/" => Nokogiri::HTML(buy_now_html)
    }

    scraper.define_singleton_method(:fetch_document) do |url|
      documents.fetch(url)
    end

    results = scraper.call

    assert_equal 7, results.size

    press_release = results.first
    assert_equal "Pokémon Reveals Two New Video Game Experiences", press_release[:title]
    assert_equal Time.zone.local(2025, 9, 12, 15, 15), press_release[:published_at]
    assert_equal Scrapers::PokemonPokopiaScraper::PRESS_RELEASE_URL, press_release[:source_url]
    assert_includes press_release[:content], "build their own Pokémon paradise"

    news_article = results.second
    assert_equal "Catch a cozy new video about Pokémon Pokopia!", news_article[:title]
    assert_equal Time.zone.local(2025, 11, 13, 17, 0), news_article[:published_at]
    assert_includes news_article[:content], "comes out March 5, 2026"

    buy_now_page = results.last
    assert_equal "Buy Now | Pokémon Pokopia", buy_now_page[:title]
    assert_equal Time.zone.local(2026, 3, 5), buy_now_page[:published_at]
    assert_includes buy_now_page[:content], "Early Purchase Bonus"
    assert_includes buy_now_page[:content], "Claim until January 31, 2027."
  end

  private

  def press_release_html
    <<~HTML
      <html>
        <body>
          <span class="date" content="2025-09-12T15:15:00.0000000" itemprop="datePublished">9/12/2025 7:15 AM</span>
          <h1 itemprop="name headline">Pokémon Reveals Two New Video Game Experiences</h1>
          <section class="bodytext">
            <p>Players can build their own Pokémon paradise.</p>
            <p>Pokémon Pokopia launches on Nintendo Switch 2 in 2026.</p>
          </section>
        </body>
      </html>
    HTML
  end

  def nintendo_news_html
    payload = {
      "props" => {
        "pageProps" => {
          "newsArticle" => {
            "title" => "Catch a cozy new video about Pokémon Pokopia!",
            "publishDate" => "2025-11-13T17:00:00.000Z",
            "body" => {
              "json" => {
                "nodeType" => "document",
                "content" => [
                  {
                    "nodeType" => "paragraph",
                    "content" => [
                      { "nodeType" => "text", "value" => "Please watch the video above for an extended look at the Pokémon Pokopia game!" }
                    ]
                  },
                  {
                    "nodeType" => "paragraph",
                    "content" => [
                      { "nodeType" => "text", "value" => "This cozy life sim is exclusive to Nintendo Switch 2 and comes out March 5, 2026." }
                    ]
                  }
                ]
              }
            }
          }
        }
      }
    }

    <<~HTML
      <html>
        <body>
          <script id="__NEXT_DATA__" type="application/json">#{payload.to_json}</script>
        </body>
      </html>
    HTML
  end

  def home_html
    <<~HTML
      <html>
        <body>
          <main>
            <h1>Available now!</h1>
            <h2>Savor the slow life with a relaxing life simulation game devoted to crafting, creating, and building.</h2>
            <p>Play as a Ditto and build a new life with Pokémon from the ground up.</p>
          </main>
        </body>
      </html>
    HTML
  end

  def explore_html
    <<~HTML
      <html>
        <body>
          <main>
            <h1>Cultivate a New World</h1>
            <p>Pokémon and people once lived happily together, but the world has withered and the humans are gone.</p>
            <p>After waking from a long slumber, a peculiar Ditto decides to restore the desolate land.</p>
          </main>
        </body>
      </html>
    HTML
  end

  def create_html
    <<~HTML
      <html>
        <body>
          <main>
            <h1>Life in Town</h1>
            <h2>Settling In</h2>
            <p>This empty land is a blank slate brimming with promising possibilities.</p>
            <p>Learn useful moves from other Pokémon.</p>
          </main>
        </body>
      </html>
    HTML
  end

  def discover_html
    <<~HTML
      <html>
        <body>
          <main>
            <h1>A Few Friendly Faces</h1>
            <p>Meet some of the unique Pokémon you can befriend.</p>
            <h2>Professor Tangrowth</h2>
            <p>This Pokémon is a vital guide to you and all the Pokémon you meet.</p>
          </main>
        </body>
      </html>
    HTML
  end

  def buy_now_html
    <<~HTML
      <html>
        <body>
          <main>
            <h1>Available now!</h1>
            <p>The digital and game-key card versions of Pokémon Pokopia are available now.</p>
            <h2>Early Purchase Bonus</h2>
            <p>You can get a Ditto rug as an early purchase bonus.</p>
            <p>Claim until January 31, 2027.</p>
          </main>
        </body>
      </html>
    HTML
  end
end
