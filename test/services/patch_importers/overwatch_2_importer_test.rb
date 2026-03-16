require "test_helper"

class PatchImporters::Overwatch2ImporterTest < ActiveSupport::TestCase
  test "imports new patches and skips existing source urls for the existing overwatch 2 game" do
    game = Game.create!(name: "Overwatch 2", slug: "overwatch-2")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Title",
      content: "Old content",
      source_url: "https://example.com/patch-1"
    )

    scraper_results = [
      {
        title: "Overwatch Retail Patch Notes - March 12, 2026",
        content: "Updated content",
        source_url: "https://example.com/patch-1",
        published_at: Time.zone.local(2026, 3, 12)
      },
      {
        title: "Overwatch Retail Patch Notes - March 10, 2026",
        content: "Fresh content",
        source_url: "https://example.com/patch-2",
        published_at: Time.zone.local(2026, 3, 10)
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

    scraper_class = Scrapers::Overwatch2Scraper.singleton_class
    original_new = Scrapers::Overwatch2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::Overwatch2Importer.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "overwatch 2").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "Overwatch Retail Patch Notes - March 12, 2026", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-2").game
  end

  test "removes placeholder patches after importing real data" do
    game = Game.create!(name: "Overwatch 2", slug: "overwatch-2")
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
            title: "Overwatch Retail Patch Notes - March 12, 2026",
            content: "Fresh content",
            source_url: "https://example.com/patch-1",
            published_at: Time.zone.local(2026, 3, 12)
          }
        ]
      end
    end.new

    scraper_class = Scrapers::Overwatch2Scraper.singleton_class
    original_new = Scrapers::Overwatch2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::Overwatch2Importer.new.call

    assert_not Patch.exists?(placeholder_patch.id)
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "finds overwatch 2 by name when the slug differs" do
    game = Game.create!(name: "Overwatch 2", slug: "legacy-overwatch-slug")

    scraper = Class.new do
      def call
        [
          {
            title: "Overwatch Retail Patch Notes - March 12, 2026",
            content: "Fresh content",
            source_url: "https://example.com/patch-1",
            published_at: Time.zone.local(2026, 3, 12)
          }
        ]
      end
    end.new

    scraper_class = Scrapers::Overwatch2Scraper.singleton_class
    original_new = Scrapers::Overwatch2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::Overwatch2Importer.new.call

    assert_equal game, Patch.find_by(source_url: "https://example.com/patch-1").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when overwatch 2 game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::Overwatch2Scraper.singleton_class
    original_new = Scrapers::Overwatch2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::Overwatch2Importer.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
