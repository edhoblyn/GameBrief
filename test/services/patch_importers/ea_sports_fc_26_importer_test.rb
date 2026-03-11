require "test_helper"

class PatchImporters::EaSportsFc26ImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls for the existing ea sports fc 26 game" do
    game = Game.create!(name: "EA Sports FC 26", slug: "ea-sports-fc-26")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Title",
      content: "Old content",
      source_url: "https://example.com/patch-1"
    )

    scraper_results = [
      {
        title: "EA SPORTS FC 26 | FC 26 Launch Update",
        content: "Updated content",
        source_url: "https://example.com/patch-1"
      },
      {
        title: "EA SPORTS FC 26 | FC 26 Pitch Notes",
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

    scraper_class = Scrapers::EaSportsFc26Scraper.singleton_class
    original_new = Scrapers::EaSportsFc26Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::EaSportsFc26Importer.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "ea sports fc 26").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "EA SPORTS FC 26 | FC 26 Launch Update", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-2").game
  end

  test "finds ea sports fc 26 by name when the slug differs" do
    game = Game.create!(name: "EA Sports FC 26", slug: "legacy-fc-slug")

    scraper = Class.new do
      def call
        [
          {
            title: "EA SPORTS FC 26 | FC 26 Launch Update",
            content: "Fresh content",
            source_url: "https://example.com/patch-1"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::EaSportsFc26Scraper.singleton_class
    original_new = Scrapers::EaSportsFc26Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::EaSportsFc26Importer.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when ea sports fc 26 game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::EaSportsFc26Scraper.singleton_class
    original_new = Scrapers::EaSportsFc26Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::EaSportsFc26Importer.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
