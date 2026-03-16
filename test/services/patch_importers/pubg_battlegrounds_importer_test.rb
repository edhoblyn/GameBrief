require "test_helper"

class PatchImporters::PubgBattlegroundsImporterTest < ActiveSupport::TestCase
  test "imports new pubg patch notes, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "PUBG: Battlegrounds", slug: "pubg-battlegrounds")
    existing_patch = Patch.create!(
      game: game,
      title: "Old PUBG patch",
      content: "Old content",
      source_url: "https://pubg.com/en/news/9809",
      published_at: Time.zone.parse("2026-03-01")
    )
    placeholder_patch = Patch.create!(
      game: game,
      title: "Placeholder PUBG patch",
      content: "Placeholder content",
      source_url: nil
    )

    scraper = Class.new do
      def call
        [
          {
            title: "Patch Notes - Update 40.2",
            content: "Updated PUBG content",
            source_url: "https://pubg.com/en/news/9809",
            published_at: Time.zone.parse("2026-03-10 06:00:00")
          },
          {
            title: "Patch Notes - Update 40.1",
            content: "Fresh PUBG content",
            source_url: "https://pubg.com/en/news/9690",
            published_at: Time.zone.parse("2026-02-03 06:00:00")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::PubgBattlegroundsScraper.singleton_class
    original_new = Scrapers::PubgBattlegroundsScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::PubgBattlegroundsImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal "Patch Notes - Update 40.2", existing_patch.reload.title
    assert_equal "Updated PUBG content", existing_patch.content
    assert_equal Time.zone.parse("2026-03-10 06:00:00").to_i, existing_patch.published_at.to_i
    assert_equal game, Patch.find_by(source_url: "https://pubg.com/en/news/9690").game
    assert_nil Patch.find_by(id: placeholder_patch.id)
  end

  test "finds pubg battlegrounds by name when the slug differs" do
    game = Game.create!(name: "PUBG: Battlegrounds", slug: "legacy-pubg")

    scraper = Class.new do
      def call
        [
          {
            title: "Patch Notes - Update 40.2",
            content: "Fresh PUBG content",
            source_url: "https://pubg.com/en/news/9809",
            published_at: Time.zone.parse("2026-03-10 06:00:00")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::PubgBattlegroundsScraper.singleton_class
    original_new = Scrapers::PubgBattlegroundsScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::PubgBattlegroundsImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://pubg.com/en/news/9809").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when the pubg battlegrounds game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::PubgBattlegroundsScraper.singleton_class
    original_new = Scrapers::PubgBattlegroundsScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::PubgBattlegroundsImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
