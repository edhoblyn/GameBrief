require "test_helper"

class PatchImporters::GenshinImpactImporterTest < ActiveSupport::TestCase
  test "imports new genshin impact updates, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "Genshin Impact", slug: "genshin-impact")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Genshin title",
      content: "Old content",
      source_url: "https://www.hoyolab.com/article/43970902",
      published_at: Time.zone.parse("2026-02-27")
    )
    placeholder_patch = Patch.create!(
      game: game,
      title: "Placeholder Genshin patch",
      content: "Placeholder content",
      source_url: nil
    )

    scraper = Class.new do
      def call
        [
          {
            title: "Version Luna V Version Details - What's New(03/05)",
            content: "Updated Genshin content",
            source_url: "https://www.hoyolab.com/article/43970902",
            published_at: Time.zone.parse("2026-02-27")
          },
          {
            title: "Version \"Luna V\" Update Maintenance Preview",
            content: "Fresh Genshin content",
            source_url: "https://www.hoyolab.com/article/43918162",
            published_at: Time.zone.parse("2026-02-23")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::GenshinImpactScraper.singleton_class
    original_new = Scrapers::GenshinImpactScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::GenshinImpactImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal "Version Luna V Version Details - What's New(03/05)", existing_patch.reload.title
    assert_equal "Updated Genshin content", existing_patch.content
    assert_equal Time.zone.parse("2026-02-27").to_i, existing_patch.published_at.to_i
    assert_equal game, Patch.find_by(source_url: "https://www.hoyolab.com/article/43918162").game
    assert_nil Patch.find_by(id: placeholder_patch.id)
  end

  test "finds genshin impact by name when the slug differs" do
    game = Game.create!(name: "Genshin Impact", slug: "legacy-genshin-impact")

    scraper = Class.new do
      def call
        [
          {
            title: "Issue Fix Details",
            content: "Fresh Genshin patch content",
            source_url: "https://www.hoyolab.com/article/43581824",
            published_at: Time.zone.parse("2025-10-20")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::GenshinImpactScraper.singleton_class
    original_new = Scrapers::GenshinImpactScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::GenshinImpactImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://www.hoyolab.com/article/43581824").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when genshin impact is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::GenshinImpactScraper.singleton_class
    original_new = Scrapers::GenshinImpactScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::GenshinImpactImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
