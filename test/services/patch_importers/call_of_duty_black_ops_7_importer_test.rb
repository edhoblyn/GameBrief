require "test_helper"

class PatchImporters::CallOfDutyBlackOps7ImporterTest < ActiveSupport::TestCase
  test "imports Call of Duty: Black Ops 7 patches for the existing game" do
    game = Game.create!(name: "Call of Duty: Black Ops 7", slug: "call-of-duty-black-ops-7")
    existing_patch = Patch.create!(
      game: game,
      title: "Old title",
      content: "Old content",
      source_url: "https://www.callofduty.com/patchnotes/2026/01/black-ops-7-launch-patch"
    )

    scraper_results = [
      {
        title: "Black Ops 7 Launch Day Patch",
        content: "Updated launch patch notes.",
        source_url: "https://www.callofduty.com/patchnotes/2026/01/black-ops-7-launch-patch",
        published_at: Time.zone.local(2026, 1, 28, 17, 0)
      },
      {
        title: "Black Ops 7 Season 1 Update",
        content: "Season 1 brings new maps and modes.",
        source_url: "https://www.callofduty.com/patchnotes/2026/02/black-ops-7-season-1-update",
        published_at: Time.zone.local(2026, 2, 4, 17, 0)
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

    scraper_class = Scrapers::CallOfDutyBlackOps7Scraper.singleton_class
    original_new = Scrapers::CallOfDutyBlackOps7Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::CallOfDutyBlackOps7Importer.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "call of duty: black ops 7").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "Black Ops 7 Launch Day Patch", existing_patch.reload.title
    assert_equal "Updated launch patch notes.", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "https://www.callofduty.com/patchnotes/2026/02/black-ops-7-season-1-update").game
  end

  test "finds Call of Duty: Black Ops 7 by name when the slug differs" do
    game = Game.create!(name: "Call of Duty: Black Ops 7", slug: "legacy-bo7")

    scraper = Class.new do
      def call
        [
          {
            title: "Black Ops 7 Season 2 Update",
            content: "New content.",
            source_url: "https://www.callofduty.com/patchnotes/2026/03/black-ops-7-season-2-update",
            published_at: Time.zone.local(2026, 3, 10)
          }
        ]
      end
    end.new

    scraper_class = Scrapers::CallOfDutyBlackOps7Scraper.singleton_class
    original_new = Scrapers::CallOfDutyBlackOps7Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::CallOfDutyBlackOps7Importer.new.call

    assert_equal game, Patch.find_by(source_url: "https://www.callofduty.com/patchnotes/2026/03/black-ops-7-season-2-update").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when the Call of Duty: Black Ops 7 game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::CallOfDutyBlackOps7Scraper.singleton_class
    original_new = Scrapers::CallOfDutyBlackOps7Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::CallOfDutyBlackOps7Importer.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
