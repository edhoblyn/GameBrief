require "test_helper"

class PatchImporters::WarzoneImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls for the existing warzone game" do
    game = Game.create!(name: "Call of Duty: Warzone", slug: "call-of-duty-warzone")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Title",
      content: "Old content",
      source_url: "https://example.com/patch-1"
    )

    scraper_results = [
      {
        title: "Patch 1 Updated",
        content: "Updated content",
        source_url: "https://example.com/patch-1"
      },
      {
        title: "Patch 2",
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

    scraper_class = Scrapers::WarzoneScraper.singleton_class
    original_new = Scrapers::WarzoneScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::WarzoneImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "call of duty: warzone").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "Patch 1 Updated", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-2").game
  end

  test "finds warzone by name when the slug differs" do
    game = Game.create!(name: "Call of Duty: Warzone", slug: "legacy-warzone-slug")

    scraper = Class.new do
      def call
        [
          {
            title: "Patch 1",
            content: "Fresh content",
            source_url: "https://example.com/patch-1"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::WarzoneScraper.singleton_class
    original_new = Scrapers::WarzoneScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::WarzoneImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when warzone game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::WarzoneScraper.singleton_class
    original_new = Scrapers::WarzoneScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::WarzoneImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
