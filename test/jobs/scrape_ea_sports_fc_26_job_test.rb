require "test_helper"

class ScrapeEaSportsFc26JobTest < ActiveJob::TestCase
  test "runs the ea sports fc 26 importer" do
    importer = Class.new do
      def call
        PatchImporters::EaSportsFc26Importer::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::EaSportsFc26Importer.singleton_class
    original_new = PatchImporters::EaSportsFc26Importer.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeEaSportsFc26Job.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
