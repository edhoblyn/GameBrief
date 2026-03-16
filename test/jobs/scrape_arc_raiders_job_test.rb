require "test_helper"

class ScrapeArcRaidersJobTest < ActiveJob::TestCase
  test "runs the arc raiders importer" do
    importer = Class.new do
      def call
        PatchImporters::ArcRaidersImporter::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::ArcRaidersImporter.singleton_class
    original_new = PatchImporters::ArcRaidersImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeArcRaidersJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
