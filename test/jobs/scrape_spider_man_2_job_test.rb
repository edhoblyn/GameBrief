require "test_helper"

class ScrapeSpiderMan2JobTest < ActiveJob::TestCase
  test "runs the spider-man 2 importer" do
    importer = Class.new do
      def call
        PatchImporters::SpiderMan2Importer::Result.new(imported: 2, skipped: 1)
      end
    end.new

    importer_class = PatchImporters::SpiderMan2Importer.singleton_class
    original_new = PatchImporters::SpiderMan2Importer.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeSpiderMan2Job.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
