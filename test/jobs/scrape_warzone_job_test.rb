require "test_helper"

class ScrapeWarzoneJobTest < ActiveJob::TestCase
  test "runs the warzone importer" do
    importer = Class.new do
      def call
        PatchImporters::WarzoneImporter::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::WarzoneImporter.singleton_class
    original_new = PatchImporters::WarzoneImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeWarzoneJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
