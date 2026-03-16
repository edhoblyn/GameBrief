require "test_helper"

class ScrapePokemonPokopiaJobTest < ActiveJob::TestCase
  test "runs the Pokémon Pokopia importer" do
    importer = Class.new do
      def call
        PatchImporters::PokemonPokopiaImporter::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::PokemonPokopiaImporter.singleton_class
    original_new = PatchImporters::PokemonPokopiaImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapePokemonPokopiaJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
