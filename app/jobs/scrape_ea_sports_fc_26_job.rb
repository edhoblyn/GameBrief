class ScrapeEaSportsFc26Job < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::EaSportsFc26Importer.new.call
    Rails.logger.info(
      "ScrapeEaSportsFc26Job: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
