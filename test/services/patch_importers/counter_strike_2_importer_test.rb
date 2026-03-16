require "test_helper"

class PatchImporters::CounterStrike2ImporterTest < ActiveSupport::TestCase
  test "imports new counter-strike 2 updates, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "Counter-Strike 2", slug: "counter-strike-2")
    existing_patch = Patch.create!(
      game: game,
      title: "Old title",
      content: "Old content",
      source_url: "https://example.com/cs2-update-1",
      published_at: Time.zone.parse("2026-03-01")
    )
    placeholder_patch = Patch.create!(
      game: game,
      title: "Placeholder patch",
      content: "Placeholder content",
      source_url: nil
    )

    scraper = Class.new do
      def call
        [
          {
            title: "Counter-Strike 2 Update",
            content: "Updated content",
            source_url: "https://example.com/cs2-update-1",
            published_at: Time.zone.parse("2026-03-11")
          },
          {
            title: "Counter-Strike 2 Update",
            content: "Fresh content",
            source_url: "https://example.com/cs2-update-2",
            published_at: Time.zone.parse("2026-03-04")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::CounterStrike2Scraper.singleton_class
    original_new = Scrapers::CounterStrike2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::CounterStrike2Importer.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal "Counter-Strike 2 Update", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal Time.zone.parse("2026-03-11").to_i, existing_patch.published_at.to_i
    assert_equal game, Patch.find_by(source_url: "https://example.com/cs2-update-2").game
    assert_nil Patch.find_by(id: placeholder_patch.id)
  end

  test "finds counter-strike 2 by name when the slug differs" do
    game = Game.create!(name: "Counter-Strike 2", slug: "legacy-counter-strike-2")

    scraper = Class.new do
      def call
        [
          {
            title: "Counter-Strike 2 Update",
            content: "Fresh content",
            source_url: "https://example.com/cs2-update-1",
            published_at: Time.zone.parse("2026-03-11")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::CounterStrike2Scraper.singleton_class
    original_new = Scrapers::CounterStrike2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::CounterStrike2Importer.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/cs2-update-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when the counter-strike 2 game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::CounterStrike2Scraper.singleton_class
    original_new = Scrapers::CounterStrike2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::CounterStrike2Importer.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
