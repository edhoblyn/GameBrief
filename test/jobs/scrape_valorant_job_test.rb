require "test_helper"

class ScrapeValorantJobTest < ActiveJob::TestCase
  test "runs the valorant importer" do
    importer = Class.new do
      def call
        PatchImporters::ValorantImporter::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::ValorantImporter.singleton_class
    original_new = PatchImporters::ValorantImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeValorantJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
