class ScrapeWarzoneJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::WarzoneImporter.new.call
    Rails.logger.info(
      "ScrapeWarzoneJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
