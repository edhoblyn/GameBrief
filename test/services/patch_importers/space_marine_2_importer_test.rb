require "test_helper"

class PatchImporters::SpaceMarine2ImporterTest < ActiveSupport::TestCase
  test "imports new space marine 2 updates, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "Warhammer 40,000: Space Marine 2", slug: "warhammer-40000-space-marine-2")
    existing_patch = Patch.create!(
      game: game,
      title: "Old title",
      content: "Old content",
      source_url: "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/356-patch-notes-12-0",
      published_at: Time.zone.parse("2026-02-24")
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
            title: "Patch Notes 12.0",
            content: "Updated content",
            source_url: "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/356-patch-notes-12-0",
            published_at: Time.zone.parse("2026-02-26")
          },
          {
            title: "Hotfix 12.1 Patch Notes",
            content: "Fresh content",
            source_url: "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/360-hotfix-12-1-patch-notes",
            published_at: Time.zone.parse("2026-03-05")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::SpaceMarine2Scraper.singleton_class
    original_new = Scrapers::SpaceMarine2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::SpaceMarine2Importer.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal "Patch Notes 12.0", existing_patch.reload.title
    assert_equal "Updated content", existing_patch.content
    assert_equal Time.zone.parse("2026-02-26").to_i, existing_patch.published_at.to_i
    assert_equal game, Patch.find_by(source_url: "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/360-hotfix-12-1-patch-notes").game
    assert_nil Patch.find_by(id: placeholder_patch.id)
  end

  test "finds space marine 2 by name when the slug differs" do
    game = Game.create!(name: "Warhammer 40,000: Space Marine 2", slug: "legacy-space-marine-2")

    scraper = Class.new do
      def call
        [
          {
            title: "Hotfix 12.1 Patch Notes",
            content: "Fresh content",
            source_url: "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/360-hotfix-12-1-patch-notes",
            published_at: Time.zone.parse("2026-03-05")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::SpaceMarine2Scraper.singleton_class
    original_new = Scrapers::SpaceMarine2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::SpaceMarine2Importer.new.call

    assert_equal game, Patch.find_by(source_url: "https://community.focus-entmt.com/focus-entertainment/space-marine-2/blogs/360-hotfix-12-1-patch-notes").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when the space marine 2 game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::SpaceMarine2Scraper.singleton_class
    original_new = Scrapers::SpaceMarine2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::SpaceMarine2Importer.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
