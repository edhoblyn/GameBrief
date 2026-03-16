require "test_helper"

class Scrapers::Overwatch2ScraperTest < ActiveSupport::TestCase
  test "collects patch entries across paginated archive pages" do
    scraper = Scrapers::Overwatch2Scraper.new
    documents = {
      Scrapers::Overwatch2Scraper::INDEX_URL => Nokogiri::HTML(current_month_html),
      "https://ga.overwatch.blizzard.com/news/patch-notes/live/2026/02" => Nokogiri::HTML(previous_month_html)
    }

    scraper.define_singleton_method(:fetch_document) do |url|
      documents.fetch(url)
    end

    results = scraper.call

    assert_equal 2, results.size

    latest_patch = results.first
    assert_equal "Overwatch Retail Patch Notes - March 12, 2026", latest_patch[:title]
    assert_equal Time.zone.local(2026, 3, 12), latest_patch[:published_at]
    assert_equal "https://ga.overwatch.blizzard.com/en-us/news/patch-notes/live/2026/03#patch-2026-03-12", latest_patch[:source_url]
    assert_includes latest_patch[:content], "Hotfix Update"
    assert_includes latest_patch[:content], "- Fixed an issue with Jetpack Cat."

    previous_patch = results.second
    assert_equal Time.zone.local(2026, 2, 25), previous_patch[:published_at]
    assert_equal "https://ga.overwatch.blizzard.com/en-us/news/patch-notes/live/2026/02#patch-2026-02-25", previous_patch[:source_url]
  end

  test "falls back to the anchor date when the visible date is missing" do
    scraper = Scrapers::Overwatch2Scraper.new
    documents = {
      Scrapers::Overwatch2Scraper::INDEX_URL => Nokogiri::HTML(missing_label_html)
    }

    scraper.define_singleton_method(:fetch_document) do |url|
      documents.fetch(url)
    end

    result = scraper.call.first

    assert_equal Time.zone.local(2026, 3, 12), result[:published_at]
  end

  private

  def current_month_html
    <<~HTML
      <html>
        <body>
          <div class="anchor" id="patch-2026-03-12"></div>
          <div class="PatchNotes-labels">March 12, 2026</div>
          <h3 class="PatchNotes-patchTitle">Overwatch Retail Patch Notes - March 12, 2026</h3>
          <div class="PatchNotes-section PatchNotes-section-generic_update">
            <h4 class="PatchNotes-sectionTitle">Hotfix Update</h4>
            <div class="PatchNotesGeneralUpdate-description">
              <p>Bug fix patch.</p>
              <ul>
                <li>Fixed an issue with Jetpack Cat.</li>
              </ul>
            </div>
          </div>
          <div class="PatchNotesTop">Top of post</div>
          <div class="PatchNotesPagination">
            <a class="PatchNotesPaginationLink--prev" href="/news/patch-notes/live/2026/02">Feb. Patch Notes</a>
          </div>
        </body>
      </html>
    HTML
  end

  def previous_month_html
    <<~HTML
      <html>
        <body>
          <div class="anchor" id="patch-2026-02-25"></div>
          <div class="PatchNotes-labels">February 25, 2026</div>
          <h3 class="PatchNotes-patchTitle">Overwatch Retail Patch Notes - February 25, 2026</h3>
          <div class="PatchNotes-section PatchNotes-section-generic_update">
            <h4 class="PatchNotes-sectionTitle">Hero Updates</h4>
            <div class="PatchNotesGeneralUpdate-description">
              <p>Balance updates are live.</p>
            </div>
          </div>
          <div class="PatchNotesTop">Top of post</div>
        </body>
      </html>
    HTML
  end

  def missing_label_html
    <<~HTML
      <html>
        <body>
          <div class="anchor" id="patch-2026-03-12"></div>
          <h3 class="PatchNotes-patchTitle">Overwatch Retail Patch Notes - March 12, 2026</h3>
          <div class="PatchNotes-section PatchNotes-section-generic_update">
            <h4 class="PatchNotes-sectionTitle">Bug Fixes</h4>
            <div class="PatchNotesGeneralUpdate-description">
              <ul>
                <li>Fixed an issue.</li>
              </ul>
            </div>
          </div>
          <div class="PatchNotesTop">Top of post</div>
        </body>
      </html>
    HTML
  end
end
