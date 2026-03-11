require "test_helper"

class PatchImporters::FortniteImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls for the existing fortnite game" do
    game = Game.create!(name: "Fortnite", slug: "fortnite")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Title",
      content: "Old content",
      source_url: "https://example.com/patch-1"
    )

    scraper_results = [
      {
        title: "Fortnite Battle Royale Update",
        content: "Updated content",
        source_url: "https://example.com/patch-1"
      },
      {
        title: "Fortnite Patch Notes",
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

    scraper_class = Scrapers::FortniteScraper.singleton_class
    original_new = Scrapers::FortniteScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::FortniteImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "fortnite").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "Fortnite Battle Royale Update", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-2").game
  end

  test "finds fortnite by name when the slug differs" do
    game = Game.create!(name: "Fortnite", slug: "legacy-fortnite-slug")

    scraper = Class.new do
      def call
        [
          {
            title: "Fortnite Battle Royale Update",
            content: "Fresh content",
            source_url: "https://example.com/patch-1"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::FortniteScraper.singleton_class
    original_new = Scrapers::FortniteScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::FortniteImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when fortnite game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::FortniteScraper.singleton_class
    original_new = Scrapers::FortniteScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::FortniteImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
