require "test_helper"

class ScrapeApexLegendsJobTest < ActiveJob::TestCase
  test "runs the apex legends importer" do
    importer = Class.new do
      def call
        PatchImporters::ApexLegendsImporter::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::ApexLegendsImporter.singleton_class
    original_new = PatchImporters::ApexLegendsImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeApexLegendsJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
