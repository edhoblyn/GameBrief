require "test_helper"

class PatchImporters::ClashRoyaleImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls for the existing clash royale game" do
    game = Game.create!(name: "Clash Royale", slug: "clash-royale")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Title",
      content: "Old content",
      source_url: "https://example.com/patch-1"
    )

    scraper_results = [
      {
        title: "March Balance Changes",
        content: "Updated content",
        source_url: "https://example.com/patch-1"
      },
      {
        title: "March Update 2026",
        content: "Fresh content",
        source_url: "https://example.com/patch-2"
      }
    ]

    scraper = Class.new do
      def initialize(results)
        @results = results
      end

      def call
        @results
      end
    end.new(scraper_results)

    scraper_class = Scrapers::ClashRoyaleScraper.singleton_class
    original_new = Scrapers::ClashRoyaleScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::ClashRoyaleImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "clash royale").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "March Balance Changes", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-2").game
  end

  test "finds clash royale by name when the slug differs" do
    game = Game.create!(name: "Clash Royale", slug: "legacy-clash-royale-slug")

    scraper = Class.new do
      def call
        [
          {
            title: "March Balance Changes",
            content: "Fresh content",
            source_url: "https://example.com/patch-1"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::ClashRoyaleScraper.singleton_class
    original_new = Scrapers::ClashRoyaleScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::ClashRoyaleImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when clash royale game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::ClashRoyaleScraper.singleton_class
    original_new = Scrapers::ClashRoyaleScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::ClashRoyaleImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
