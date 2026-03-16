require "test_helper"

class PatchImporters::LeagueOfLegendsImporterTest < ActiveSupport::TestCase
  test "imports new patches, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "League of Legends", slug: "league-of-legends")
    existing_patch = Patch.create!(
      game: game,
      title: "Old title",
      content: "Old content",
      source_url: "https://example.com/patch-26-5",
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
            title: "League of Legends Patch 26.5 Notes",
            content: "Updated content",
            source_url: "https://example.com/patch-26-5",
            published_at: Time.zone.parse("2026-03-03")
          },
          {
            title: "Patch 26.4 Notes",
            content: "Fresh content",
            source_url: "https://example.com/patch-26-4",
            published_at: Time.zone.parse("2026-02-18")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::LeagueOfLegendsScraper.singleton_class
    original_new = Scrapers::LeagueOfLegendsScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::LeagueOfLegendsImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal "League of Legends Patch 26.5 Notes", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal Time.zone.parse("2026-03-03").to_i, existing_patch.published_at.to_i
    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-26-4").game
    assert_nil Patch.find_by(id: placeholder_patch.id)
  end

  test "finds league of legends by name when the slug differs" do
    game = Game.create!(name: "League of Legends", slug: "legacy-league-slug")

    scraper = Class.new do
      def call
        [
          {
            title: "League of Legends Patch 26.5 Notes",
            content: "Fresh content",
            source_url: "https://example.com/patch-26-5",
            published_at: Time.zone.parse("2026-03-03")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::LeagueOfLegendsScraper.singleton_class
    original_new = Scrapers::LeagueOfLegendsScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::LeagueOfLegendsImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-26-5").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when the league of legends game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::LeagueOfLegendsScraper.singleton_class
    original_new = Scrapers::LeagueOfLegendsScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::LeagueOfLegendsImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
