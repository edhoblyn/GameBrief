require "test_helper"

class ScrapeCyberpunk2077JobTest < ActiveJob::TestCase
  test "runs the cyberpunk 2077 importer" do
    importer = Class.new do
      def call
        PatchImporters::Cyberpunk2077Importer::Result.new(imported: 2, skipped: 1)
      end
    end.new

    importer_class = PatchImporters::Cyberpunk2077Importer.singleton_class
    original_new = PatchImporters::Cyberpunk2077Importer.method(:new)
    importer_class.define_method(:new) { importer }

    assert_nothing_raised do
      ScrapeCyberpunk2077Job.perform_now
    end
  ensure
    importer_class.define_method(:new, original_new)
  end
end
