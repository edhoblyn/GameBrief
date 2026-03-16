require "test_helper"

class ScrapeSpaceMarine2JobTest < ActiveJob::TestCase
  test "runs the space marine 2 importer" do
    importer = Class.new do
      def call
        PatchImporters::SpaceMarine2Importer::Result.new(imported: 2, skipped: 1)
      end
    end.new

    importer_class = PatchImporters::SpaceMarine2Importer.singleton_class
    original_new = PatchImporters::SpaceMarine2Importer.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeSpaceMarine2Job.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
