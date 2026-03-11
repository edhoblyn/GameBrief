require "test_helper"

class ScrapeClashOfClansJobTest < ActiveJob::TestCase
  test "runs the clash of clans importer" do
    importer = Class.new do
      def call
        PatchImporters::ClashOfClansImporter::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::ClashOfClansImporter.singleton_class
    original_new = PatchImporters::ClashOfClansImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeClashOfClansJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
