require "test_helper"

class PatchImporters::Helldivers2ImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls for the existing helldivers 2 game" do
    game = Game.create!(name: "Helldivers 2", slug: "helldivers-2")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Title",
      content: "Old content",
      source_url: "https://example.com/patch-1"
    )

    scraper_results = [
      {
        title: "PATCH 01.003.100",
        content: "Updated content",
        source_url: "https://example.com/patch-1"
      },
      {
        title: "Into the Unjust: 6.0.1",
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

    scraper_class = Scrapers::Helldivers2Scraper.singleton_class
    original_new = Scrapers::Helldivers2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::Helldivers2Importer.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "helldivers 2").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "PATCH 01.003.100", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-2").game
  end

  test "finds helldivers 2 by name when the slug differs" do
    game = Game.create!(name: "Helldivers 2", slug: "legacy-helldivers-slug")

    scraper = Class.new do
      def call
        [
          {
            title: "PATCH 01.003.100",
            content: "Fresh content",
            source_url: "https://example.com/patch-1"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::Helldivers2Scraper.singleton_class
    original_new = Scrapers::Helldivers2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::Helldivers2Importer.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when helldivers 2 game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::Helldivers2Scraper.singleton_class
    original_new = Scrapers::Helldivers2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::Helldivers2Importer.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
