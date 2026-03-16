require "test_helper"

class PatchImporters::BaldursGate3ImporterTest < ActiveSupport::TestCase
  test "imports new baldur's gate 3 updates, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "Baldur's Gate 3", slug: "baldurs-gate-3")
    existing_patch = Patch.create!(
      game: game,
      title: "Old BG3 title",
      content: "Old content",
      source_url: "https://store.steampowered.com/news/app/1086940/view/568143233911096621",
      published_at: Time.zone.parse("2025-11-20")
    )
    placeholder_patch = Patch.create!(
      game: game,
      title: "Placeholder BG3 patch",
      content: "Placeholder content",
      source_url: nil
    )

    scraper = Class.new do
      def call
        [
          {
            title: "Hotfix #35 Now Live!",
            content: "Updated BG3 content",
            source_url: "https://store.steampowered.com/news/app/1086940/view/568143233911096621",
            published_at: Time.zone.parse("2025-11-20")
          },
          {
            title: "Hotfix #34 Now Live!",
            content: "Fresh BG3 content",
            source_url: "https://store.steampowered.com/news/app/1086940/view/511843343389426278",
            published_at: Time.zone.parse("2025-09-23")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::BaldursGate3Scraper.singleton_class
    original_new = Scrapers::BaldursGate3Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::BaldursGate3Importer.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal "Hotfix #35 Now Live!", existing_patch.reload.title
    assert_equal "Updated BG3 content", existing_patch.content
    assert_equal Time.zone.parse("2025-11-20").to_i, existing_patch.published_at.to_i
    assert_equal game, Patch.find_by(source_url: "https://store.steampowered.com/news/app/1086940/view/511843343389426278").game
    assert_nil Patch.find_by(id: placeholder_patch.id)
  end

  test "finds baldur's gate 3 by name when the slug differs" do
    game = Game.create!(name: "Baldur's Gate 3", slug: "legacy-baldurs-gate-3")

    scraper = Class.new do
      def call
        [
          {
            title: "The Final Patch: New Subclasses, Photo Mode, and Cross-Play",
            content: "Fresh BG3 patch content",
            source_url: "https://store.steampowered.com/news/app/1086940/view/538849539213231622",
            published_at: Time.zone.parse("2025-04-15")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::BaldursGate3Scraper.singleton_class
    original_new = Scrapers::BaldursGate3Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::BaldursGate3Importer.new.call

    assert_equal game, Patch.find_by(source_url: "https://store.steampowered.com/news/app/1086940/view/538849539213231622").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when baldur's gate 3 is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::BaldursGate3Scraper.singleton_class
    original_new = Scrapers::BaldursGate3Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::BaldursGate3Importer.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
