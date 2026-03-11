require "test_helper"

class PatchImporters::MarvelRivalsImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls" do
    game = Game.create!(name: "Marvel Rivals", slug: "marvel-rivals")
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

    scraper_class = Scrapers::MarvelRivalsScraper.singleton_class
    original_new = Scrapers::MarvelRivalsScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::MarvelRivalsImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "Patch 1 Updated", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
  end

  test "raises when marvel rivals game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::MarvelRivalsScraper.singleton_class
    original_new = Scrapers::MarvelRivalsScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::MarvelRivalsImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
