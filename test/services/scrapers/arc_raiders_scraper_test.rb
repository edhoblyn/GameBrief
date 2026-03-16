require "test_helper"

class Scrapers::ArcRaidersScraperTest < ActiveSupport::TestCase
  test "collects recent arc raiders patch notes from the official news hub" do
    scraper = Scrapers::ArcRaidersScraper.new
    recent_date = 1.month.ago.to_date
    older_date = 7.months.ago.to_date
    documents = {
      Scrapers::ArcRaidersScraper::INDEX_URL => Nokogiri::HTML(index_html(recent_date:, older_date:)),
      "https://arcraiders.com/news/patch-notes-1-19-0" => Nokogiri::HTML(article_html(
        title: "Patch Notes 1.19.0",
        published_at: recent_date.strftime("%B %-d, %Y"),
        body: "<p>Raiders!</p><ul><li>Fixed an inventory issue.</li><li>Added two new haircuts.</li></ul>"
      ))
    }

    scraper.define_singleton_method(:fetch_document) do |url|
      documents.fetch(url)
    end

    results = scraper.call

    assert_equal 1, results.size

    patch = results.first
    assert_equal "Patch Notes 1.19.0", patch[:title]
    assert_equal "https://arcraiders.com/news/patch-notes-1-19-0", patch[:source_url]
    assert_equal Time.zone.parse(recent_date.strftime("%B %-d, %Y")), patch[:published_at]
    assert_includes patch[:content], "Raiders!"
    assert_includes patch[:content], "- Fixed an inventory issue."
  end

  private

  def index_html(recent_date:, older_date:)
    <<~HTML
      <html>
        <body>
          <a class="news-article-card_container__xsniv" href="/news/patch-notes-1-19-0">
            <div class="news-article-card_tags__1Ygpc">
              <div data-text="Patch Notes">Patch Notes</div>
            </div>
            <div class="news-article-card_title__7LpPs">Patch Notes 1.19.0</div>
            <div class="news-article-card_date__fJqI_">#{recent_date.strftime("%B %-d, %Y")}</div>
          </a>
          <a class="news-article-card_container__xsniv" href="/news/community-post">
            <div class="news-article-card_tags__1Ygpc"></div>
            <div class="news-article-card_title__7LpPs">Community competition</div>
            <div class="news-article-card_date__fJqI_">#{recent_date.strftime("%B %-d, %Y")}</div>
          </a>
          <a class="news-article-card_container__xsniv" href="/news/patch-notes-legacy">
            <div class="news-article-card_tags__1Ygpc">
              <div data-text="Patch Notes">Patch Notes</div>
            </div>
            <div class="news-article-card_title__7LpPs">Patch Notes 0.9.0</div>
            <div class="news-article-card_date__fJqI_">#{older_date.strftime("%B %-d, %Y")}</div>
          </a>
        </body>
      </html>
    HTML
  end

  def article_html(title:, published_at:, body:)
    <<~HTML
      <html>
        <body>
          <div class="news-article-page_header___YvCu">
            <div class="news-article-page_titleAndTags__ZiEj3">
              <a data-text="Patch Notes" class="news-article-tag_tag__8Q__4">Patch Notes</a>
              <h1 class="news-article-page_title__oCpmA">#{title}</h1>
            </div>
            <div>#{published_at}</div>
          </div>
          <div class="article_article__Do3j2">
            <div class="payload-richtext">
              #{body}
            </div>
          </div>
        </body>
      </html>
    HTML
  end
end
