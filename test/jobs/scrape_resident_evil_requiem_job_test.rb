require "test_helper"

class ScrapeResidentEvilRequiemJobTest < ActiveJob::TestCase
  test "runs the resident evil requiem importer" do
    importer = Class.new do
      def call
        PatchImporters::ResidentEvilRequiemImporter::Result.new(imported: 2, skipped: 1)
      end
    end.new

    importer_class = PatchImporters::ResidentEvilRequiemImporter.singleton_class
    original_new = PatchImporters::ResidentEvilRequiemImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeResidentEvilRequiemJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
