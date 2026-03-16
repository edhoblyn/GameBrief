require "test_helper"

class PatchImporters::Battlefield6ImporterTest < ActiveSupport::TestCase
  test "imports new battlefield 6 updates, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "Battlefield 6", slug: "battlefield-6")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Battlefield 6 Update",
      content: "Old content",
      source_url: "https://www.ea.com/games/battlefield/battlefield-6/news/battlefield-6-game-update-1-2-2-0",
      published_at: Time.zone.parse("2026-03-01")
    )
    placeholder_patch = Patch.create!(
      game: game,
      title: "Placeholder Battlefield 6 Patch",
      content: "Placeholder content"
    )

    scraper_results = [
      {
        title: "BATTLEFIELD 6 GAME UPDATE 1.2.2.0",
        content: "Updated content",
        source_url: "https://www.ea.com/games/battlefield/battlefield-6/news/battlefield-6-game-update-1-2-2-0",
        published_at: Time.zone.parse("2026-03-13")
      },
      {
        title: "BATTLEFIELD 6 - COMMUNITY UPDATE - ONGOING QUALITY OF LIFE IMPROVEMENTS",
        content: "Fresh content",
        source_url: "https://www.ea.com/games/battlefield/battlefield-6/news/battlefield-6-community-update-ongoing-quality-of-life-improvements",
        published_at: Time.zone.parse("2026-03-05")
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

    scraper_class = Scrapers::Battlefield6Scraper.singleton_class
    original_new = Scrapers::Battlefield6Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::Battlefield6Importer.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "BATTLEFIELD 6 GAME UPDATE 1.2.2.0", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal Time.zone.parse("2026-03-13").to_i, existing_patch.published_at.to_i
    assert_nil Patch.find_by(id: placeholder_patch.id)
    assert_equal game, Patch.find_by(source_url: "https://www.ea.com/games/battlefield/battlefield-6/news/battlefield-6-community-update-ongoing-quality-of-life-improvements").game
  end

  test "finds battlefield 6 by name when the slug differs" do
    game = Game.create!(name: "Battlefield 6", slug: "legacy-battlefield-6")

    scraper = Class.new do
      def call
        [
          {
            title: "BATTLEFIELD 6 GAME UPDATE 1.2.2.0",
            content: "Fresh content",
            source_url: "https://www.ea.com/games/battlefield/battlefield-6/news/battlefield-6-game-update-1-2-2-0"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::Battlefield6Scraper.singleton_class
    original_new = Scrapers::Battlefield6Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::Battlefield6Importer.new.call

    assert_equal game, Patch.find_by(source_url: "https://www.ea.com/games/battlefield/battlefield-6/news/battlefield-6-game-update-1-2-2-0").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when battlefield 6 game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::Battlefield6Scraper.singleton_class
    original_new = Scrapers::Battlefield6Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::Battlefield6Importer.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
