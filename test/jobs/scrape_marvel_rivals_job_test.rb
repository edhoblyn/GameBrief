require "test_helper"

class ScrapeMarvelRivalsJobTest < ActiveJob::TestCase
  test "runs the marvel rivals importer" do
    importer = Class.new do
      def call
        PatchImporters::MarvelRivalsImporter::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::MarvelRivalsImporter.singleton_class
    original_new = PatchImporters::MarvelRivalsImporter.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeMarvelRivalsJob.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
