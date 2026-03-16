require "test_helper"

class ScrapeLeagueOfLegendsJobTest < ActiveJob::TestCase
  test "runs the league of legends importer" do
    importer = Class.new do
      def call
        PatchImporters::LeagueOfLegendsImporter::Result.new(imported: 2, skipped: 1)
      end
    end.new

    importer_class = PatchImporters::LeagueOfLegendsImporter.singleton_class
    original_new = PatchImporters::LeagueOfLegendsImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeLeagueOfLegendsJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
