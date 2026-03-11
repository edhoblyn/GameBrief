class ScrapeHelldivers2Job < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::Helldivers2Importer.new.call
    Rails.logger.info(
      "ScrapeHelldivers2Job: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
