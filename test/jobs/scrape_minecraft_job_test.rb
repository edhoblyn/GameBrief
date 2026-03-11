require "test_helper"

class ScrapeMinecraftJobTest < ActiveJob::TestCase
  test "runs the minecraft importer" do
    importer = Class.new do
      def call
        PatchImporters::MinecraftImporter::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::MinecraftImporter.singleton_class
    original_new = PatchImporters::MinecraftImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeMinecraftJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
