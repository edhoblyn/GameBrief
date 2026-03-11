require "test_helper"

class PatchImporters::ValorantImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls for the existing valorant game" do
    game = Game.create!(name: "Valorant", slug: "valorant")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Title",
      content: "Old content",
      source_url: "https://example.com/patch-1"
    )

    scraper_results = [
      {
        title: "VALORANT Patch Notes 12.02",
        content: "Updated content",
        source_url: "https://example.com/patch-1"
      },
      {
        title: "VALORANT Patch Notes 12.01",
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

    scraper_class = Scrapers::ValorantScraper.singleton_class
    original_new = Scrapers::ValorantScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::ValorantImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "valorant").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "VALORANT Patch Notes 12.02", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-2").game
  end

  test "finds valorant by name when the slug differs" do
    game = Game.create!(name: "Valorant", slug: "legacy-valorant-slug")

    scraper = Class.new do
      def call
        [
          {
            title: "VALORANT Patch Notes 12.02",
            content: "Fresh content",
            source_url: "https://example.com/patch-1"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::ValorantScraper.singleton_class
    original_new = Scrapers::ValorantScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::ValorantImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when valorant game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::ValorantScraper.singleton_class
    original_new = Scrapers::ValorantScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::ValorantImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
