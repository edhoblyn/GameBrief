require "test_helper"

class ScrapeFortniteJobTest < ActiveJob::TestCase
  test "runs the fortnite importer" do
    importer = Class.new do
      def call
        PatchImporters::FortniteImporter::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::FortniteImporter.singleton_class
    original_new = PatchImporters::FortniteImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeFortniteJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
