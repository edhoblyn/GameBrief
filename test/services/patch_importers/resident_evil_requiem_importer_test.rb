require "test_helper"

class PatchImporters::ResidentEvilRequiemImporterTest < ActiveSupport::TestCase
  test "imports new announcement-backed patches, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "Resident Evil Requiem", slug: "resident-evil-requiem")
    placeholder = Patch.create!(game: game, title: "Placeholder", content: "Fake patch")
    existing_patch = Patch.create!(
      game: game,
      title: "Old update title",
      content: "Old content",
      source_url: "https://steamcommunity.com/gid/123/announcements/detail/1",
      published_at: Time.zone.local(2026, 2, 27)
    )

    scraper_results = [
      {
        title: "Resident Evil Requiem out now!",
        content: "Updated launch notice",
        source_url: "https://steamcommunity.com/gid/123/announcements/detail/1",
        published_at: Time.zone.local(2026, 2, 27)
      },
      {
        title: "Notice of Update Distribution",
        content: "Real update notes",
        source_url: "https://steamcommunity.com/gid/123/announcements/detail/2",
        published_at: Time.zone.local(2026, 3, 5)
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

    scraper_class = Scrapers::ResidentEvilRequiemScraper.singleton_class
    original_new = Scrapers::ResidentEvilRequiemScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::ResidentEvilRequiemImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_nil Patch.find_by(id: placeholder.id)
    assert_equal 2, Patch.count
    assert_equal "Resident Evil Requiem out now!", existing_patch.reload.title
    assert_equal "Updated launch notice", existing_patch.content
    assert_equal Time.zone.local(2026, 3, 5).to_i, Patch.find_by(source_url: "https://steamcommunity.com/gid/123/announcements/detail/2").published_at.to_i
  end

  test "raises when resident evil requiem game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::ResidentEvilRequiemScraper.singleton_class
    original_new = Scrapers::ResidentEvilRequiemScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::ResidentEvilRequiemImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
