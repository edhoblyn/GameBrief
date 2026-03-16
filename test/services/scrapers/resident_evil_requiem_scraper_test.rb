require "test_helper"

class Scrapers::ResidentEvilRequiemScraperTest < ActiveSupport::TestCase
  test "collects live announcement entries that represent real game updates" do
    scraper = Scrapers::ResidentEvilRequiemScraper.new
    html = sample_html
    scraper.define_singleton_method(:fetch_document) do |_url|
      Nokogiri::HTML(html)
    end

    results = scraper.call

    assert_equal 3, results.size

    latest_update = results.first
    assert_equal "Notice regarding DualSense wireless controller feature support", latest_update[:title]
    assert_equal "https://steamcommunity.com/gid/123/announcements/detail/3", latest_update[:source_url]
    assert_equal Time.zone.local(Time.zone.today.year, 3, 6), latest_update[:published_at]
    assert_includes latest_update[:content], "supporting the adaptive trigger"

    patch_update = results.second
    assert_equal "Notice of Update Distribution", patch_update[:title]
    assert_equal Time.zone.local(Time.zone.today.year, 3, 5), patch_update[:published_at]
    assert_includes patch_update[:content], "Issues which blocked player progress"
    assert_includes patch_update[:content], "Multiple fixes to improve overall playability"

    launch_notice = results.third
    assert_equal "Resident Evil Requiem out now!", launch_notice[:title]
    assert_equal Time.zone.local(2026, 2, 27), launch_notice[:published_at]
  end

  private

  def sample_html
    <<~HTML
      <html>
        <body>
          <div class="apphub_Card Announcement_Card" data-modal-content-url="https://steamcommunity.com/gid/123/announcements/detail/3">
            <div class="apphub_CardContentNewsTitle">Notice regarding DualSense wireless controller feature support</div>
            <div class="apphub_CardContentNewsDate">6 Mar</div>
            <div class="apphub_CardTextContent">
              <p>Thank you to everyone for playing Resident Evil Requiem!</p>
              <p>We've heard your feedback and are currently working on supporting the adaptive trigger and vibration functions for the DualSense wireless controller for the PC version of the game.</p>
            </div>
          </div>
          <div class="apphub_Card Announcement_Card" data-modal-content-url="https://steamcommunity.com/gid/123/announcements/detail/2">
            <div class="apphub_CardContentNewsTitle">Notice of Update Distribution</div>
            <div class="apphub_CardContentNewsDate">5 Mar</div>
            <div class="apphub_CardTextContent">
              We have released an update including the following modifications and fixes.<br><br>
              ・Issues which blocked player progress under specific conditions have been fixed.<br>
              ・Multiple fixes to improve overall playability have also been implemented.
            </div>
          </div>
          <div class="apphub_Card Announcement_Card" data-modal-content-url="https://steamcommunity.com/gid/123/announcements/detail/1">
            <div class="apphub_CardContentNewsTitle">Resident Evil Requiem out now!</div>
            <div class="apphub_CardContentNewsDate">27 Feb, 2026</div>
            <div class="apphub_CardTextContent">
              <p>The game is now available worldwide.</p>
            </div>
          </div>
          <div class="apphub_Card Announcement_Card" data-modal-content-url="https://steamcommunity.com/gid/123/announcements/detail/0">
            <div class="apphub_CardContentNewsTitle">Resident Evil Showcase - Recap</div>
            <div class="apphub_CardContentNewsDate">16 Jan, 2026</div>
            <div class="apphub_CardTextContent">
              <p>Trailer recap only.</p>
            </div>
          </div>
        </body>
      </html>
    HTML
  end
end
