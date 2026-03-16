require "test_helper"

class PatchImporters::SpiderMan2ImporterTest < ActiveSupport::TestCase
  test "imports new spider-man 2 updates, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "Marvel's Spider-Man 2", slug: "marvels-spider-man-2")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Spider-Man title",
      content: "Old content",
      source_url: "https://store.steampowered.com/news/app/2651280/view/530973313390870870",
      published_at: Time.zone.parse("2025-05-22")
    )
    placeholder_patch = Patch.create!(
      game: game,
      title: "Placeholder Spider-Man patch",
      content: "Placeholder content",
      source_url: nil
    )

    scraper = Class.new do
      def call
        [
          {
            title: "Marvel's Spider-Man 2 PC – Patch 10 Release Notes",
            content: "Updated Spider-Man content",
            source_url: "https://store.steampowered.com/news/app/2651280/view/530973313390870870",
            published_at: Time.zone.parse("2025-05-22")
          },
          {
            title: "Marvel's Spider-Man 2 PC - Patch 10 Hotfix",
            content: "Fresh Spider-Man content",
            source_url: "https://store.steampowered.com/news/app/2651280/view/530973313390871694",
            published_at: Time.zone.parse("2025-05-28")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::SpiderMan2Scraper.singleton_class
    original_new = Scrapers::SpiderMan2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::SpiderMan2Importer.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal "Marvel's Spider-Man 2 PC – Patch 10 Release Notes", existing_patch.reload.title
    assert_equal "Updated Spider-Man content", existing_patch.content
    assert_equal Time.zone.parse("2025-05-22").to_i, existing_patch.published_at.to_i
    assert_equal game, Patch.find_by(source_url: "https://store.steampowered.com/news/app/2651280/view/530973313390871694").game
    assert_nil Patch.find_by(id: placeholder_patch.id)
  end

  test "finds spider-man 2 by name when the slug differs" do
    game = Game.create!(name: "Marvel's Spider-Man 2", slug: "legacy-marvels-spider-man-2")

    scraper = Class.new do
      def call
        [
          {
            title: "Marvel's Spider-Man 2 PC – Patch 6 Release Notes",
            content: "Fresh Spider-Man patch content",
            source_url: "https://store.steampowered.com/news/app/2651280/view/536596558933657553",
            published_at: Time.zone.parse("2025-03-20")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::SpiderMan2Scraper.singleton_class
    original_new = Scrapers::SpiderMan2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::SpiderMan2Importer.new.call

    assert_equal game, Patch.find_by(source_url: "https://store.steampowered.com/news/app/2651280/view/536596558933657553").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when marvel's spider-man 2 game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::SpiderMan2Scraper.singleton_class
    original_new = Scrapers::SpiderMan2Scraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::SpiderMan2Importer.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
