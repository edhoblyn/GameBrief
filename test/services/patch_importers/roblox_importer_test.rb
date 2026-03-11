require "test_helper"

class PatchImporters::RobloxImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls for the existing roblox game" do
    game = Game.create!(name: "Roblox", slug: "roblox")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Title",
      content: "Old content",
      source_url: "https://example.com/release-notes-1"
    )

    scraper_results = [
      {
        title: "Release notes for 555",
        content: "Updated content",
        source_url: "https://example.com/release-notes-1"
      },
      {
        title: "Release notes for 556",
        content: "Fresh content",
        source_url: "https://example.com/release-notes-2"
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

    scraper_class = Scrapers::RobloxScraper.singleton_class
    original_new = Scrapers::RobloxScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::RobloxImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "roblox").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "Release notes for 555", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://example.com/release-notes-2").game
  end

  test "finds roblox by name when the slug differs" do
    game = Game.create!(name: "Roblox", slug: "legacy-roblox-slug")

    scraper = Class.new do
      def call
        [
          {
            title: "Release notes for 555",
            content: "Fresh content",
            source_url: "https://example.com/release-notes-1"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::RobloxScraper.singleton_class
    original_new = Scrapers::RobloxScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::RobloxImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/release-notes-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when roblox game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::RobloxScraper.singleton_class
    original_new = Scrapers::RobloxScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::RobloxImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
