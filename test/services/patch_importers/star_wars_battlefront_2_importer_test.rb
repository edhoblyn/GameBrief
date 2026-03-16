require "test_helper"

class PatchImporters::StarWarsBattlefront2ImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls for the existing battlefront ii game" do
    game = Game.create!(name: "Star Wars Battlefront II", slug: "star-wars-battlefront-ii")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Title",
      content: "Old content",
      source_url: "https://example.com/patch-1"
    )

    scraper_results = [
      {
        title: "After 2+ Years of Free Content, the Vision for Battlefront II is Now Complete",
        content: "Updated content",
        source_url: "https://example.com/patch-1"
      },
      {
        title: "The Latest Star Wars Battlefront II Roadmap",
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

    scraper_class = Scrapers::StarWarsBattlefront2Scraper.singleton_class
    original_new = Scrapers::StarWarsBattlefront2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::StarWarsBattlefront2Importer.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "star wars battlefront ii").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "After 2+ Years of Free Content, the Vision for Battlefront II is Now Complete", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-2").game
  end

  test "finds battlefront ii by name when the slug differs" do
    game = Game.create!(name: "Star Wars Battlefront II", slug: "legacy-battlefront-ii")

    scraper = Class.new do
      def call
        [
          {
            title: "The Latest Star Wars Battlefront II Roadmap",
            content: "Fresh content",
            source_url: "https://example.com/patch-1"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::StarWarsBattlefront2Scraper.singleton_class
    original_new = Scrapers::StarWarsBattlefront2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::StarWarsBattlefront2Importer.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when battlefront ii game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::StarWarsBattlefront2Scraper.singleton_class
    original_new = Scrapers::StarWarsBattlefront2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::StarWarsBattlefront2Importer.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
