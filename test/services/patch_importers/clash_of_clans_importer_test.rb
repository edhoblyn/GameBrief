require "test_helper"

class PatchImporters::ClashOfClansImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls for the existing clash of clans game" do
    game = Game.create!(name: "Clash of Clans", slug: "clash-of-clans")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Title",
      content: "Old content",
      source_url: "https://example.com/patch-1"
    )

    scraper_results = [
      {
        title: "TOWN HALL 18 Crash Lands! - Update",
        content: "Updated content",
        source_url: "https://example.com/patch-1"
      },
      {
        title: "Welcome to Let's Get Crafty Update!",
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

    scraper_class = Scrapers::ClashOfClansScraper.singleton_class
    original_new = Scrapers::ClashOfClansScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::ClashOfClansImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "clash of clans").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "TOWN HALL 18 Crash Lands! - Update", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-2").game
  end

  test "finds clash of clans by name when the slug differs" do
    game = Game.create!(name: "Clash of Clans", slug: "legacy-clash-of-clans-slug")

    scraper = Class.new do
      def call
        [
          {
            title: "TOWN HALL 18 Crash Lands! - Update",
            content: "Fresh content",
            source_url: "https://example.com/patch-1"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::ClashOfClansScraper.singleton_class
    original_new = Scrapers::ClashOfClansScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::ClashOfClansImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when clash of clans game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::ClashOfClansScraper.singleton_class
    original_new = Scrapers::ClashOfClansScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::ClashOfClansImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
