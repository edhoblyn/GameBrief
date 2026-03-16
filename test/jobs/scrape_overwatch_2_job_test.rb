require "test_helper"

class ScrapeOverwatch2JobTest < ActiveJob::TestCase
  test "runs the overwatch 2 importer" do
    importer = Class.new do
      def call
        PatchImporters::Overwatch2Importer::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::Overwatch2Importer.singleton_class
    original_new = PatchImporters::Overwatch2Importer.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeOverwatch2Job.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
