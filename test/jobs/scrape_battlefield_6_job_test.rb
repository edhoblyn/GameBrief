require "test_helper"

class ScrapeBattlefield6JobTest < ActiveJob::TestCase
  test "runs the battlefield 6 importer" do
    importer = Class.new do
      def call
        PatchImporters::Battlefield6Importer::Result.new(imported: 2, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::Battlefield6Importer.singleton_class
    original_new = PatchImporters::Battlefield6Importer.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeBattlefield6Job.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
