require "test_helper"

class ScrapeCounterStrike2JobTest < ActiveJob::TestCase
  test "runs the counter-strike 2 importer" do
    importer = Class.new do
      def call
        PatchImporters::CounterStrike2Importer::Result.new(imported: 2, skipped: 1)
      end
    end.new

    importer_class = PatchImporters::CounterStrike2Importer.singleton_class
    original_new = PatchImporters::CounterStrike2Importer.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeCounterStrike2Job.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
