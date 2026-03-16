class ScrapeSpaceMarine2Job < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::SpaceMarine2Importer.new.call
    Rails.logger.info(
      "ScrapeSpaceMarine2Job: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
