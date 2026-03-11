require "test_helper"

class ScrapeClashRoyaleJobTest < ActiveJob::TestCase
  test "runs the clash royale importer" do
    importer = Class.new do
      def call
        PatchImporters::ClashRoyaleImporter::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::ClashRoyaleImporter.singleton_class
    original_new = PatchImporters::ClashRoyaleImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeClashRoyaleJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
