require "test_helper"

class ScrapeCallOfDutyBlackOps7JobTest < ActiveJob::TestCase
  test "runs the Call of Duty: Black Ops 7 importer" do
    importer = Class.new do
      def call
        PatchImporters::CallOfDutyBlackOps7Importer::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::CallOfDutyBlackOps7Importer.singleton_class
    original_new = PatchImporters::CallOfDutyBlackOps7Importer.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeCallOfDutyBlackOps7Job.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
