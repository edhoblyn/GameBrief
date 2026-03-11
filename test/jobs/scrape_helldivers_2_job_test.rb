require "test_helper"

class ScrapeHelldivers2JobTest < ActiveJob::TestCase
  test "runs the helldivers 2 importer" do
    importer = Class.new do
      def call
        PatchImporters::Helldivers2Importer::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::Helldivers2Importer.singleton_class
    original_new = PatchImporters::Helldivers2Importer.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeHelldivers2Job.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
