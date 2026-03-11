require "test_helper"

class ScrapeDestiny2JobTest < ActiveJob::TestCase
  test "runs the destiny 2 importer" do
    importer = Class.new do
      def call
        PatchImporters::Destiny2Importer::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::Destiny2Importer.singleton_class
    original_new = PatchImporters::Destiny2Importer.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeDestiny2Job.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
