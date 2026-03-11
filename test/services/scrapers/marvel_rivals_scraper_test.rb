require "test_helper"

class Scrapers::MarvelRivalsScraperTest < ActiveSupport::TestCase
  test "normalizes clearly incorrect future year in detail date" do
    scraper = Scrapers::MarvelRivalsScraper.new
    published_at = Time.zone.parse("2026/12/31")
    title = "Marvel Rivals Version 20260101 Patch Notes"

    normalized = scraper.send(:normalize_detail_date, published_at, title)

    assert_equal Time.zone.parse("2025/12/31").to_i, normalized.to_i
  end

  test "keeps valid detail date unchanged" do
    scraper = Scrapers::MarvelRivalsScraper.new
    published_at = Time.zone.parse("2026/03/04")
    title = "Marvel Rivals Version 20260305 Patch Notes"

    normalized = scraper.send(:normalize_detail_date, published_at, title)

    assert_equal published_at.to_i, normalized.to_i
  end
end
