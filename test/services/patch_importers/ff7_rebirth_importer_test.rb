require "test_helper"

class PatchImporters::Ff7RebirthImporterTest < ActiveSupport::TestCase
  test "imports new FF7 Rebirth updates, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "Final Fantasy VII Rebirth", slug: "final-fantasy-vii-rebirth")
    existing_patch = Patch.create!(
      game: game,
      title: "Old FF7 title",
      content: "Old content",
      source_url: "https://store.steampowered.com/news/app/2909400/view/514098767258978258",
      published_at: Time.zone.parse("2025-11-04")
    )
    placeholder_patch = Patch.create!(
      game: game,
      title: "Placeholder FF7 patch",
      content: "Placeholder content",
      source_url: nil
    )

    scraper = Class.new do
      def call
        [
          {
            title: "Version 1.004 Release Notice",
            content: "Added DLSS Multi Frame Generation support.",
            source_url: "https://store.steampowered.com/news/app/2909400/view/514098767258978258",
            published_at: Time.zone.parse("2025-11-04")
          },
          {
            title: "Version 1.003 Release Notice",
            content: "Frame generation compatibility improvements.",
            source_url: "https://store.steampowered.com/news/app/2909400/view/527588008025654786",
            published_at: Time.zone.parse("2025-03-06")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::Ff7RebirthScraper.singleton_class
    original_new = Scrapers::Ff7RebirthScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::Ff7RebirthImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal "Version 1.004 Release Notice", existing_patch.reload.title
    assert_equal "Added DLSS Multi Frame Generation support.", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://store.steampowered.com/news/app/2909400/view/527588008025654786").game
    assert_nil Patch.find_by(id: placeholder_patch.id)
  end

  test "finds FF7 Rebirth by name when the slug differs" do
    game = Game.create!(name: "Final Fantasy VII Rebirth", slug: "legacy-ff7-rebirth")

    scraper = Class.new do
      def call
        [
          {
            title: "Version 1.004 Release Notice",
            content: "DLSS support added.",
            source_url: "https://store.steampowered.com/news/app/2909400/view/514098767258978258",
            published_at: Time.zone.parse("2025-11-04")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::Ff7RebirthScraper.singleton_class
    original_new = Scrapers::Ff7RebirthScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::Ff7RebirthImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://store.steampowered.com/news/app/2909400/view/514098767258978258").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when Final Fantasy VII Rebirth is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::Ff7RebirthScraper.singleton_class
    original_new = Scrapers::Ff7RebirthScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::Ff7RebirthImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
