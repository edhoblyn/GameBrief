require "test_helper"

class ScrapeRobloxJobTest < ActiveJob::TestCase
  test "runs the roblox importer" do
    importer = Class.new do
      def call
        PatchImporters::RobloxImporter::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::RobloxImporter.singleton_class
    original_new = PatchImporters::RobloxImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeRobloxJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
