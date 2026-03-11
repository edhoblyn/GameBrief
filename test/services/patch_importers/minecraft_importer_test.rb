require "test_helper"

class PatchImporters::MinecraftImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls for the existing minecraft game" do
    game = Game.create!(name: "Minecraft", slug: "minecraft")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Title",
      content: "Old content",
      source_url: "https://example.com/patch-1"
    )

    scraper_results = [
      {
        title: "Minecraft: Java Edition 1.21.11",
        content: "Updated content",
        source_url: "https://example.com/patch-1"
      },
      {
        title: "Minecraft: Bedrock Edition 1.21.130",
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

    scraper_class = Scrapers::MinecraftScraper.singleton_class
    original_new = Scrapers::MinecraftScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::MinecraftImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "minecraft").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "Minecraft: Java Edition 1.21.11", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-2").game
  end

  test "finds minecraft by name when the slug differs" do
    game = Game.create!(name: "Minecraft", slug: "legacy-minecraft-slug")

    scraper = Class.new do
      def call
        [
          {
            title: "Minecraft: Java Edition 1.21.11",
            content: "Fresh content",
            source_url: "https://example.com/patch-1"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::MinecraftScraper.singleton_class
    original_new = Scrapers::MinecraftScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::MinecraftImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when minecraft game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::MinecraftScraper.singleton_class
    original_new = Scrapers::MinecraftScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::MinecraftImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
