require "test_helper"

class PatchScrapeRunnerTest < ActiveSupport::TestCase
  test "runs a configured importer" do
    importer = Class.new do
      Result = Struct.new(:imported, :skipped, keyword_init: true)

      def call
        Result.new(imported: 2, skipped: 1)
      end
    end.new

    importer_class = PatchImporters::MarvelRivalsImporter.singleton_class
    original_new = PatchImporters::MarvelRivalsImporter.method(:new)
    importer_class.define_method(:new) { importer }

    result = PatchScrapeRunner.run("marvel_rivals")

    assert_equal "marvel_rivals", result.source
    assert_equal "Marvel Rivals", result.label
    assert_equal 2, result.imported
    assert_equal 1, result.skipped
  ensure
    importer_class.define_method(:new, original_new)
  end

  test "raises on unknown source" do
    assert_raises(KeyError) do
      PatchScrapeRunner.run("unknown_game")
    end
  end

  test "treats blocked sources as non-scrapeable" do
    assert_not PatchScrapeRunner.scrapeable?("fortnite")
    assert_not PatchScrapeRunner.scrapeable?("destiny_2")
    assert_not PatchScrapeRunner.scrapeable?("helldivers_2")
    assert_not PatchScrapeRunner.scrapeable?("minecraft")
  end

  test "only returns scrapeable sources for runnable sources" do
    assert_includes PatchScrapeRunner.runnable_sources, "apex_legends"
    assert_includes PatchScrapeRunner.runnable_sources, "overwatch_2"
    assert_includes PatchScrapeRunner.runnable_sources, "resident_evil_requiem"
    assert_not_includes PatchScrapeRunner.runnable_sources, "fortnite"
    assert_not_includes PatchScrapeRunner.runnable_sources, "helldivers_2"
    assert_not_includes PatchScrapeRunner.runnable_sources, "minecraft"
  end
end
