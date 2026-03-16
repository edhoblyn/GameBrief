require "test_helper"

class PatchImporters::HorizonForbiddenWestImporterTest < ActiveSupport::TestCase
  test "imports new horizon forbidden west updates, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "Horizon Forbidden West", slug: "horizon-forbidden-west")
    existing_patch = Patch.create!(
      game: game,
      title: "Old Horizon title",
      content: "Old content",
      source_url: "https://store.steampowered.com/news/app/2420110/view/4169846932049799888",
      published_at: Time.zone.parse("2024-05-02")
    )
    placeholder_patch = Patch.create!(
      game: game,
      title: "Placeholder Horizon patch",
      content: "Placeholder content",
      source_url: nil
    )

    scraper = Class.new do
      def call
        [
          {
            title: "Horizon Forbidden West Complete Edition 1.4.59.0 Release Notes",
            content: "Updated Horizon content",
            source_url: "https://store.steampowered.com/news/app/2420110/view/4169846932049799888",
            published_at: Time.zone.parse("2024-05-02")
          },
          {
            title: "AMD FSR 3.1 is now available in Horizon Forbidden West Complete Edition",
            content: "Fresh Horizon content",
            source_url: "https://store.steampowered.com/news/app/2420110/view/4229524700808157679",
            published_at: Time.zone.parse("2024-06-27")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::HorizonForbiddenWestScraper.singleton_class
    original_new = Scrapers::HorizonForbiddenWestScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::HorizonForbiddenWestImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal "Horizon Forbidden West Complete Edition 1.4.59.0 Release Notes", existing_patch.reload.title
    assert_equal "Updated Horizon content", existing_patch.content
    assert_equal Time.zone.parse("2024-05-02").to_i, existing_patch.published_at.to_i
    assert_equal game, Patch.find_by(source_url: "https://store.steampowered.com/news/app/2420110/view/4229524700808157679").game
    assert_nil Patch.find_by(id: placeholder_patch.id)
  end

  test "finds horizon forbidden west by name when the slug differs" do
    game = Game.create!(name: "Horizon Forbidden West", slug: "legacy-horizon-forbidden-west")

    scraper = Class.new do
      def call
        [
          {
            title: "Horizon Forbidden West Complete Edition Hotfix 1.3.57.0",
            content: "Fresh Horizon hotfix content",
            source_url: "https://store.steampowered.com/news/app/2420110/view/4172098098015834680",
            published_at: Time.zone.parse("2024-04-25")
          }
        ]
      end
    end.new

    scraper_class = Scrapers::HorizonForbiddenWestScraper.singleton_class
    original_new = Scrapers::HorizonForbiddenWestScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::HorizonForbiddenWestImporter.new.call

    assert_equal game, Patch.find_by(source_url: "https://store.steampowered.com/news/app/2420110/view/4172098098015834680").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when the horizon forbidden west game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::HorizonForbiddenWestScraper.singleton_class
    original_new = Scrapers::HorizonForbiddenWestScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::HorizonForbiddenWestImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
