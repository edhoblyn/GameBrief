require "test_helper"

class PatchImporters::PokemonPokopiaImporterTest < ActiveSupport::TestCase
  test "imports curated official Pokémon Pokopia updates for the existing game" do
    game = Game.create!(name: "Pokémon Pokopia", slug: "pokemon-pokopia")
    existing_patch = Patch.create!(
      game: game,
      title: "Old title",
      content: "Old content",
      source_url: Scrapers::PokemonPokopiaScraper::PRESS_RELEASE_URL
    )

    scraper_results = [
      {
        title: "Pokémon Reveals Two New Video Game Experiences",
        content: "Updated reveal copy",
        source_url: Scrapers::PokemonPokopiaScraper::PRESS_RELEASE_URL,
        published_at: Time.zone.local(2025, 9, 12, 15, 15)
      },
      {
        title: "Buy Now | Pokémon Pokopia",
        content: "The game is available now.",
        source_url: "#{Scrapers::PokemonPokopiaScraper::MICROSITE_URL}buy-now/",
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

    scraper_class = Scrapers::PokemonPokopiaScraper.singleton_class
    original_new = Scrapers::PokemonPokopiaScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    result = PatchImporters::PokemonPokopiaImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal 1, Game.where("LOWER(name) = ?", "pokémon pokopia").count
  ensure
    scraper_class.define_method(:new, original_new)

    assert_equal 2, Patch.count
    assert_equal "Pokémon Reveals Two New Video Game Experiences", existing_patch.reload.title
    assert_equal "Updated reveal copy", existing_patch.content
    assert_equal game, Patch.find_by(source_url: "#{Scrapers::PokemonPokopiaScraper::MICROSITE_URL}buy-now/").game
  end

  test "finds Pokémon Pokopia by name when the slug differs" do
    game = Game.create!(name: "Pokémon Pokopia", slug: "legacy-pokopia")

    scraper = Class.new do
      def call
        [
          {
            title: "Official Site",
            content: "Fresh content",
            source_url: "#{Scrapers::PokemonPokopiaScraper::MICROSITE_URL}discover/",
            published_at: Time.zone.local(2026, 3, 5)
          }
        ]
      end
    end.new

    scraper_class = Scrapers::PokemonPokopiaScraper.singleton_class
    original_new = Scrapers::PokemonPokopiaScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    PatchImporters::PokemonPokopiaImporter.new.call

    assert_equal game, Patch.find_by(source_url: "#{Scrapers::PokemonPokopiaScraper::MICROSITE_URL}discover/").game
  ensure
    scraper_class.define_method(:new, original_new)
  end

  test "raises when the Pokémon Pokopia game is missing" do
    scraper = Class.new do
      def call
        []
      end
    end.new

    scraper_class = Scrapers::PokemonPokopiaScraper.singleton_class
    original_new = Scrapers::PokemonPokopiaScraper.method(:new)
    scraper_class.define_method(:new) { scraper }

    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::PokemonPokopiaImporter.new.call
    end
  ensure
    scraper_class.define_method(:new, original_new)
  end
end
