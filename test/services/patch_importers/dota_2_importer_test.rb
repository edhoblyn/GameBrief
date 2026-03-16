require "test_helper"

class PatchImporters::Dota2ImporterTest < ActiveSupport::TestCase
  test "imports new dota 2 updates, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "Dota 2", slug: "dota-2")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Dota title",
      content: "Old content",
      source_url: "https://store.steampowered.com/news/app/570/view/533247947228316765",
      published_at: Time.zone.parse("2026-01-30")
    )
    placeholder_patch = Patch.create!(
      game: game,
      title: "Placeholder Dota patch",
      content: "Placeholder content",
      source_url: nil
    )

    scraper = Class.new do
      def call
        [
          {
            title: "Dota 2 Update - 1/30/2026",
            content: "Updated Dota content",
            source_url: "https://store.steampowered.com/news/app/570/view/533247947228316765",
            published_at: Time.zone.parse("2026-01-30")
          },
          {
            title: "7.40c Gameplay Patch",
            content: "Fresh Dota content",
            source_url: "https://store.steampowered.com/news/app/570/view/537750912402194535",
            published_at: Time.zone.parse("2026-01-21")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::Dota2Scraper.singleton_class
    original_new = Scrapers::Dota2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::Dota2Importer.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal "Dota 2 Update - 1/30/2026", existing_patch.reload.title
    assert_equal "Updated Dota content", existing_patch.content
    assert_equal Time.zone.parse("2026-01-30").to_i, existing_patch.published_at.to_i
    assert_equal game, Patch.find_by(source_url: "https://store.steampowered.com/news/app/570/view/537750912402194535").game
    assert_nil Patch.find_by(id: placeholder_patch.id)
  end

  test "finds dota 2 by name when the slug differs" do
    game = Game.create!(name: "Dota 2", slug: "legacy-dota-2")

    scraper = Class.new do
      def call
        [
          {
            title: "Introducing Largo and Patch 7.40",
            content: "Fresh Dota patch content",
            source_url: "https://store.steampowered.com/news/app/570/view/533243594419470467",
            published_at: Time.zone.parse("2025-12-15")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::Dota2Scraper.singleton_class
    original_new = Scrapers::Dota2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::Dota2Importer.new.call

    assert_equal game, Patch.find_by(source_url: "https://store.steampowered.com/news/app/570/view/533243594419470467").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when dota 2 is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::Dota2Scraper.singleton_class
    original_new = Scrapers::Dota2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::Dota2Importer.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
