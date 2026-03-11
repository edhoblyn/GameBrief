require "test_helper"

class PatchImporters::ApexLegendsImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls for the existing apex legends game" do
    game = Game.create!(name: "Apex Legends", slug: "apex-legends")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Title",
      content: "Old content",
      source_url: "https://example.com/patch-1"
    )

    scraper_results = [
      {
        title: "Apex Legends Patch Notes",
        content: "Updated content",
        source_url: "https://example.com/patch-1"
      },
      {
        title: "Apex Legends Showdown Patch Notes",
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

    scraper_class = Scrapers::ApexLegendsScraper.singleton_class
    original_new = Scrapers::ApexLegendsScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::ApexLegendsImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "apex legends").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "Apex Legends Patch Notes", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-2").game
  end

  test "finds apex legends by name when the slug differs" do
    game = Game.create!(name: "Apex Legends", slug: "legacy-apex-slug")

    scraper = Class.new do
      def call
        [
          {
            title: "Apex Legends Patch Notes",
            content: "Fresh content",
            source_url: "https://example.com/patch-1"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::ApexLegendsScraper.singleton_class
    original_new = Scrapers::ApexLegendsScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::ApexLegendsImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when apex legends game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::ApexLegendsScraper.singleton_class
    original_new = Scrapers::ApexLegendsScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::ApexLegendsImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
