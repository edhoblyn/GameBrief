require "test_helper"

class PatchImporters::Cyberpunk2077ImporterTest < ActiveSupport::TestCase
  test "imports new cyberpunk 2077 updates, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "Cyberpunk 2077", slug: "cyberpunk-2077")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Cyberpunk title",
      content: "Old content",
      source_url: "https://store.steampowered.com/news/app/1091500/view/503961862016073928",
      published_at: Time.zone.parse("2025-09-11")
    )
    placeholder_patch = Patch.create!(
      game: game,
      title: "Placeholder Cyberpunk patch",
      content: "Placeholder content",
      source_url: nil
    )

    scraper = Class.new do
      def call
        [
          {
            title: "Patch 2.31",
            content: "Updated Cyberpunk content",
            source_url: "https://store.steampowered.com/news/app/1091500/view/503961862016073928",
            published_at: Time.zone.parse("2025-09-11")
          },
          {
            title: "Update 2.3 Patch Notes",
            content: "Fresh Cyberpunk content",
            source_url: "https://store.steampowered.com/news/app/1091500/view/510711823303967305",
            published_at: Time.zone.parse("2025-07-16")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::Cyberpunk2077Scraper.singleton_class
    original_new = Scrapers::Cyberpunk2077Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::Cyberpunk2077Importer.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal "Patch 2.31", existing_patch.reload.title
    assert_equal "Updated Cyberpunk content", existing_patch.content
    assert_equal Time.zone.parse("2025-09-11").to_i, existing_patch.published_at.to_i
    assert_equal game, Patch.find_by(source_url: "https://store.steampowered.com/news/app/1091500/view/510711823303967305").game
    assert_nil Patch.find_by(id: placeholder_patch.id)
  end

  test "finds cyberpunk 2077 by name when the slug differs" do
    game = Game.create!(name: "Cyberpunk 2077", slug: "legacy-cyberpunk-2077")

    scraper = Class.new do
      def call
        [
          {
            title: "Patch 2.21",
            content: "Fresh Cyberpunk patch content",
            source_url: "https://store.steampowered.com/news/app/1091500/view/538843836072329454",
            published_at: Time.zone.parse("2025-01-23")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::Cyberpunk2077Scraper.singleton_class
    original_new = Scrapers::Cyberpunk2077Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::Cyberpunk2077Importer.new.call

    assert_equal game, Patch.find_by(source_url: "https://store.steampowered.com/news/app/1091500/view/538843836072329454").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when the cyberpunk 2077 game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::Cyberpunk2077Scraper.singleton_class
    original_new = Scrapers::Cyberpunk2077Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::Cyberpunk2077Importer.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
