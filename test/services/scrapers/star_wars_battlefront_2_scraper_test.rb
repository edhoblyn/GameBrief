require "test_helper"

class Scrapers::StarWarsBattlefront2ScraperTest < ActiveSupport::TestCase
  test "collects battlefront ii update articles from the star wars news hub" do
    scraper = Scrapers::StarWarsBattlefront2Scraper.new
    documents = {
      Scrapers::StarWarsBattlefront2Scraper::INDEX_URL => Nokogiri::HTML(index_html),
      "https://www.ea.com/en-us/games/starwars/news/letter-to-the-community-original-era-content" => Nokogiri::HTML(article_html(
        title: "After 2+ Years of Free Content, the Vision for Battlefront II is Now Complete",
        published_at: "2020-04-28T14:00Z",
        body: "<p>Scarif arrives for Supremacy.</p><ul><li>Scarif joins Co-Op.</li></ul>"
      )),
      "https://www.ea.com/en-us/games/starwars/news/roadmap-august-2019-update" => Nokogiri::HTML(article_html(
        title: "The Latest Star Wars Battlefront II Roadmap",
        published_at: "2019-08-20T14:00Z",
        body: "<p>New content is planned for the fall.</p>"
      ))
    }

    scraper.define_singleton_method(:fetch_document) do |url|
      documents.fetch(url)
    end

    results = scraper.call

    assert_equal 2, results.size

    latest_patch = results.first
    assert_equal "After 2+ Years of Free Content, the Vision for Battlefront II is Now Complete", latest_patch[:title]
    assert_equal "https://www.ea.com/en-us/games/starwars/news/letter-to-the-community-original-era-content", latest_patch[:source_url]
    assert_equal Time.zone.parse("2020-04-28T14:00Z"), latest_patch[:published_at]
    assert_includes latest_patch[:content], "Scarif arrives for Supremacy."
    assert_includes latest_patch[:content], "- Scarif joins Co-Op."

    roadmap_patch = results.second
    assert_equal "https://www.ea.com/en-us/games/starwars/news/roadmap-august-2019-update", roadmap_patch[:source_url]
    assert_equal Time.zone.parse("2019-08-20T14:00Z"), roadmap_patch[:published_at]
  end

  test "falls back to the card date when the article lacks published metadata" do
    scraper = Scrapers::StarWarsBattlefront2Scraper.new
    documents = {
      Scrapers::StarWarsBattlefront2Scraper::INDEX_URL => Nokogiri::HTML(index_html),
      "https://www.ea.com/en-us/games/starwars/news/letter-to-the-community-original-era-content" => Nokogiri::HTML(article_without_date_html),
      "https://www.ea.com/en-us/games/starwars/news/roadmap-august-2019-update" => Nokogiri::HTML(article_without_date_html(title: "The Latest Star Wars Battlefront II Roadmap"))
    }

    scraper.define_singleton_method(:fetch_document) do |url|
      documents.fetch(url)
    end

    result = scraper.call.first

    assert_equal Time.zone.parse("Apr 28, 2020"), result[:published_at]
  end

  private

  def index_html
    <<~HTML
      <html>
        <body>
          <ea-tile eyebrow-text="STAR WARS™ Battlefront™ II" eyebrow-secondary-text="Apr 28, 2020" title-text="After 2+ Years of Free Content, the Vision for Battlefront II is Now Complete">
            <ea-cta link-url="/en-us/games/starwars/news/letter-to-the-community-original-era-content"></ea-cta>
          </ea-tile>
          <ea-tile eyebrow-text="STAR WARS™ Battlefront™ II" eyebrow-secondary-text="Feb 19, 2020" title-text="Making the Sounds of Star Wars Battlefront II">
            <ea-cta link-url="/en-us/games/starwars/news/making-the-sounds-of-swbf2"></ea-cta>
          </ea-tile>
          <ea-tile eyebrow-text="STAR WARS™ Battlefront™ II" eyebrow-secondary-text="Aug 20, 2019" title-text="The Latest Star Wars Battlefront II Roadmap">
            <ea-cta link-url="/en-us/games/starwars/news/roadmap-august-2019-update"></ea-cta>
          </ea-tile>
          <ea-tile eyebrow-text="STAR WARS Jedi: Fallen Order™" eyebrow-secondary-text="Apr 1, 2020" title-text="Unrelated article">
            <ea-cta link-url="/en-us/games/starwars/news/unrelated"></ea-cta>
          </ea-tile>
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

  def article_without_date_html(title: "After 2+ Years of Free Content, the Vision for Battlefront II is Now Complete")
    <<~HTML
      <html>
        <body>
          <main>
            <h1>#{title}</h1>
            <p>Fresh official content.</p>
          </main>
        </body>
      </html>
    HTML
  end
end
