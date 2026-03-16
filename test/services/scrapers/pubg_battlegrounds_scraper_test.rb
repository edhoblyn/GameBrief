require "test_helper"

class Scrapers::PubgBattlegroundsScraperTest < ActiveSupport::TestCase
  test "collects recent pubg patch notes from the official patch-notes index" do
    travel_to Time.zone.local(2026, 3, 16, 12, 0, 0) do
      scraper = Scrapers::PubgBattlegroundsScraper.new
      index_html = index_page_html
      documents = {
        "https://pubg.com/en/news/9809" => Nokogiri::HTML(detail_page_html(
          canonical_url: "https://pubg.com/en/news/9809",
          heading: "40.2 Highlights",
          first_item: "PC: March 11, 00:00 - 08:30",
          second_heading: "PUBG: 9th Anniversary",
          second_item: "A special 9th Anniversary statue awaits you on the starting island!"
        )),
        "https://pubg.com/en/news/9690" => Nokogiri::HTML(detail_page_html(
          canonical_url: "https://pubg.com/en/news/9690",
          heading: "40.1 Highlights",
          first_item: "Introduced the new survivor pass rewards.",
          second_heading: "Gameplay",
          second_item: "Adjusted weapon balance for the first February update."
        ))
      }

      scraper.define_singleton_method(:fetch_html) do |_url|
        index_html
      end

      scraper.define_singleton_method(:fetch_document) do |url|
        documents.fetch(url)
      end

      results = scraper.call

      assert_equal 2, results.size

      latest_patch = results.first
      assert_equal "Patch Notes - Update 40.2", latest_patch[:title]
      assert_equal "https://pubg.com/en/news/9809", latest_patch[:source_url]
      assert_equal Time.zone.parse("2026-03-10 06:00:00").to_i, latest_patch[:published_at].to_i
      assert_includes latest_patch[:content], "40.2 Highlights"
      assert_includes latest_patch[:content], "- PC: March 11, 00:00 - 08:30"
      assert_includes latest_patch[:content], "PUBG: 9th Anniversary"
      assert_includes latest_patch[:content], "- A special 9th Anniversary statue awaits you on the starting island!"
      assert_not_includes latest_patch[:content], "video teaser"

      previous_patch = results.second
      assert_equal "Patch Notes - Update 40.1", previous_patch[:title]
      assert_equal Time.zone.parse("2026-02-03 06:00:00").to_i, previous_patch[:published_at].to_i
      assert_includes previous_patch[:content], "40.1 Highlights"
    end
  end

  private

  def index_page_html
    <<~HTML
      <html>
        <body>
          <script>
            window.__NUXT__=(function(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O){return {fetch:{"data-v-2a235801:0":{news:{posts:[
              {createdAt:"2026-03-04 05:24:01",identifier:h,postId:9809,labels:[e,f],category:c,manualPeriodYn:g,manualPeriodType:i,displayStartTime:"2026-03-10 06:00:00",postContentId:24957,lang:j,inputType:k,title:"Patch Notes - Update 40.2",landingType:l,summary:"Introducing Update 40.2",images:[{key:m,imageUrl:"https:\\u002F\\u002Fexample.com\\u002F40-2.jpg"}],totalViewCnt:d,totalLikeCnt:d},
              {createdAt:"2026-01-19 05:30:53",identifier:h,postId:9690,labels:[e,f],category:c,manualPeriodYn:g,manualPeriodType:i,displayStartTime:"2026-02-03 06:00:00",postContentId:24350,lang:j,inputType:k,title:"Patch Notes - Update 40.1",landingType:l,summary:"Introducing Update 40.1",images:[{key:m,imageUrl:"https:\\u002F\\u002Fexample.com\\u002F40-1.jpg"}],totalViewCnt:d,totalLikeCnt:d},
              {createdAt:"2025-08-21 03:54:25",identifier:h,postId:9087,labels:[e,f],category:c,manualPeriodYn:g,manualPeriodType:i,displayStartTime:"2025-09-09 06:00:00",postContentId:20935,lang:j,inputType:k,title:"Patch Notes - Update 37.2",landingType:l,summary:"Too old for lookback",images:[{key:m,imageUrl:"https:\\u002F\\u002Fexample.com\\u002F37-2.jpg"}],totalViewCnt:d,totalLikeCnt:d}
            ]}}}}("","patch_notes","patch_notes",0,"label_pc","label_console","N","news","none","en","LTR","SELF","thumb","GENERAL","patchnote_highlight","YOUTUBE",true,"ALL","/en/news","all","PATCH NOTES","/en/news?category=patch_notes","notice","ANNOUNCEMENT","/en/news?category=notice","labs","ARCADE","/en/news?category=labs","dev_notes","Dev Letter","/en/news?category=dev_notes","universe","UNIVERSE","/en/news?category=universe","searchType","TITLE_AND_CONTENT","TITLE","searchText","label","https://api-foc.krafton.com","/"));
          </script>
        </body>
      </html>
    HTML
  end

  def detail_page_html(canonical_url:, heading:, first_item:, second_heading:, second_item:)
    <<~HTML
      <html>
        <head>
          <link rel="canonical" href="#{canonical_url}">
        </head>
        <body>
          <section class="news-detail__content">
            <article>
              <div class="content-template__inner fr-view">
                <div>
                  <h2>#{heading}</h2>
                  <p><img src="https://example.com/banner.png" alt="banner"></p>
                  <p><span class="fr-video">video teaser</span></p>
                  <ul>
                    <li><p>#{first_item}</p></li>
                  </ul>
                  <hr>
                  <h2>#{second_heading}</h2>
                  <ul>
                    <li><p>#{second_item}</p></li>
                  </ul>
                </div>
              </div>
            </article>
          </section>
        </body>
      </html>
    HTML
  end
end
