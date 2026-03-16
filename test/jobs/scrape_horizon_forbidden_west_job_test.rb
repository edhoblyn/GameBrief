require "test_helper"

class ScrapeHorizonForbiddenWestJobTest < ActiveJob::TestCase
  test "runs the horizon forbidden west importer" do
    importer = Class.new do
      def call
        PatchImporters::HorizonForbiddenWestImporter::Result.new(imported: 2, skipped: 1)
      end
    end.new

    importer_class = PatchImporters::HorizonForbiddenWestImporter.singleton_class
    original_new = PatchImporters::HorizonForbiddenWestImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeHorizonForbiddenWestJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
