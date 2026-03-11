require "test_helper"

class PatchImporters::Destiny2ImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls for the existing destiny 2 game" do
    game = Game.create!(name: "Destiny 2", slug: "destiny-2")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Title",
      content: "Old content",
      source_url: "https://example.com/patch-1"
    )

    scraper_results = [
      {
        title: "Destiny 2 Update 9.1.0",
        content: "Updated content",
        source_url: "https://example.com/patch-1"
      },
      {
        title: "Destiny 2 Update 9.1.0.2",
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

    scraper_class = Scrapers::Destiny2Scraper.singleton_class
    original_new = Scrapers::Destiny2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::Destiny2Importer.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "destiny 2").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "Destiny 2 Update 9.1.0", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-2").game
  end

  test "finds destiny 2 by name when the slug differs" do
    game = Game.create!(name: "Destiny 2", slug: "legacy-destiny-slug")

    scraper = Class.new do
      def call
        [
          {
            title: "Destiny 2 Update 9.1.0",
            content: "Fresh content",
            source_url: "https://example.com/patch-1"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::Destiny2Scraper.singleton_class
    original_new = Scrapers::Destiny2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::Destiny2Importer.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when destiny 2 game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::Destiny2Scraper.singleton_class
    original_new = Scrapers::Destiny2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::Destiny2Importer.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
