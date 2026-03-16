require "test_helper"

class PatchImporters::ArcRaidersImporterTest < ActiveSupport::TestCase
  test "imports new patches, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "ARC Raiders", slug: "arc-raiders")
    existing_patch = Patch.create!(
      game: game,
      title: "Old ARC Raiders Patch",
      content: "Old content",
      source_url: "https://arcraiders.com/news/patch-notes-1-19-0",
      published_at: Time.zone.parse("2026-03-03")
    )
    placeholder_patch = Patch.create!(
      game: game,
      title: "Placeholder ARC Patch",
      content: "Placeholder content"
    )

    scraper_results = [
      {
        title: "Patch Notes 1.19.0",
        content: "Updated content",
        source_url: "https://arcraiders.com/news/patch-notes-1-19-0",
        published_at: Time.zone.parse("2026-03-10")
      },
      {
        title: "Patch Notes 1.18.0",
        content: "Fresh content",
        source_url: "https://arcraiders.com/news/patch-notes-1-18-0",
        published_at: Time.zone.parse("2026-03-03")
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

    scraper_class = Scrapers::ArcRaidersScraper.singleton_class
    original_new = Scrapers::ArcRaidersScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::ArcRaidersImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "Patch Notes 1.19.0", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal Time.zone.parse("2026-03-10").to_i, existing_patch.published_at.to_i
    assert_nil Patch.find_by(id: placeholder_patch.id)
    assert_equal game, Patch.find_by(source_url: "https://arcraiders.com/news/patch-notes-1-18-0").game
  end

  test "finds arc raiders by name when the slug differs" do
    game = Game.create!(name: "ARC Raiders", slug: "legacy-arc-raiders")

    scraper = Class.new do
      def call
        [
          {
            title: "Patch Notes 1.19.0",
            content: "Fresh content",
            source_url: "https://arcraiders.com/news/patch-notes-1-19-0"
          }
        ]
      end
    end.new

    scraper_class = Scrapers::ArcRaidersScraper.singleton_class
    original_new = Scrapers::ArcRaidersScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::ArcRaidersImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://arcraiders.com/news/patch-notes-1-19-0").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when arc raiders game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::ArcRaidersScraper.singleton_class
    original_new = Scrapers::ArcRaidersScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::ArcRaidersImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
