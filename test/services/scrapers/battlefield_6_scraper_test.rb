require "test_helper"

class Scrapers::Battlefield6ScraperTest < ActiveSupport::TestCase
  test "collects recent battlefield 6 game updates and community updates" do
    scraper = Scrapers::Battlefield6Scraper.new
    recent_date = 1.month.ago.to_date
    second_recent_date = 3.weeks.ago.to_date
    older_date = 7.months.ago.to_date
    documents = {
      Scrapers::Battlefield6Scraper::INDEX_URL => Nokogiri::HTML(index_html(recent_date:, second_recent_date:, older_date:)),
      "https://www.ea.com/games/battlefield/battlefield-6/news/battlefield-6-game-update-1-2-2-0" => Nokogiri::HTML(article_html(
        title: "BATTLEFIELD 6 GAME UPDATE 1.2.2.0",
        published_at: recent_date.iso8601,
        body: "<p>TABLE OF CONTENTS:</p><button>New Content</button><p>Season 2 launches alongside this update.</p><h2>CHANGELOG</h2><p>PLAYER:</p><p>Networking improvements shipped.</p>"
      )),
      "https://www.ea.com/games/battlefield/battlefield-6/news/battlefield-6-community-update-ongoing-quality-of-life-improvements" => Nokogiri::HTML(article_html(
        title: "BATTLEFIELD 6 - COMMUNITY UPDATE - ONGOING QUALITY OF LIFE IMPROVEMENTS",
        published_at: second_recent_date.iso8601,
        body: "<p>Hey everyone,</p><h3>Hit Registration / Netcode</h3><p>We are continuing to refine combat reliability.</p>"
      ))
    }

    scraper.define_singleton_method(:fetch_document) do |url|
      documents.fetch(url)
    end

    results = scraper.call

    assert_equal 2, results.size

    game_update = results.first
    assert_equal "BATTLEFIELD 6 GAME UPDATE 1.2.2.0", game_update[:title]
    assert_equal "https://www.ea.com/games/battlefield/battlefield-6/news/battlefield-6-game-update-1-2-2-0", game_update[:source_url]
    assert_equal Time.zone.parse(recent_date.iso8601), game_update[:published_at]
    assert_includes game_update[:content], "Season 2 launches alongside this update."
    assert_includes game_update[:content], "CHANGELOG"
    assert_includes game_update[:content], "PLAYER:"
    assert_includes game_update[:content], "Networking improvements shipped."
    assert_not_includes game_update[:content], "TABLE OF CONTENTS:"

    community_update = results.second
    assert_equal "BATTLEFIELD 6 - COMMUNITY UPDATE - ONGOING QUALITY OF LIFE IMPROVEMENTS", community_update[:title]
    assert_includes community_update[:content], "Hit Registration / Netcode"
  end

  private

  def index_html(recent_date:, second_recent_date:, older_date:)
    <<~HTML
      <html>
        <body>
          <a href="/games/battlefield/battlefield-6/news/battlefield-6-game-update-1-2-2-0">
            <div class="Card_content__abc">
              <div>Game Updates</div>
              <span>#{recent_date.strftime("%B %-d, %Y")}</span>
              <h3>BATTLEFIELD 6 GAME UPDATE 1.2.2.0</h3>
            </div>
          </a>
          <a href="/games/battlefield/battlefield-6/news/battlefield-6-community-update-ongoing-quality-of-life-improvements">
            <div class="Card_content__abc">
              <div>News Article</div>
              <span>#{second_recent_date.strftime("%B %-d, %Y")}</span>
              <h3>BATTLEFIELD 6 - COMMUNITY UPDATE - ONGOING QUALITY OF LIFE IMPROVEMENTS</h3>
            </div>
          </a>
          <a href="/games/battlefield/battlefield-6/news/free-trial-guide">
            <div class="Card_content__abc">
              <div>Guides</div>
              <span>#{recent_date.strftime("%B %-d, %Y")}</span>
              <h3>BATTLEFIELD 6 SEASON 2 FREE TRIAL GUIDE</h3>
            </div>
          </a>
          <a href="/games/battlefield/battlefield-6/news/battlefield-6-game-update-1-0-0-0">
            <div class="Card_content__abc">
              <div>Game Updates</div>
              <span>#{older_date.strftime("%B %-d, %Y")}</span>
              <h3>BATTLEFIELD 6 GAME UPDATE 1.0.0.0</h3>
            </div>
          </a>
        </body>
      </html>
    HTML
  end

  def article_html(title:, published_at:, body:)
    body_with_classes = body
      .gsub("<p", '<p class="articleSlug_articleTypography__IOsqC"')
      .gsub("<h2", '<h2 class="articleSlug_articleTypography__IOsqC"')
      .gsub("<h3", '<h3 class="articleSlug_articleTypography__IOsqC"')

    <<~HTML
      <html>
        <head>
          <meta property="article:published_time" content="#{published_at}">
        </head>
        <body>
          <section class="Section_section__0qsnR">
            <div class="Section_customAlignment__31WNE">
              <h1>#{title}</h1>
              #{body_with_classes}
            </div>
          </section>
        </body>
      </html>
    HTML
  end
end
