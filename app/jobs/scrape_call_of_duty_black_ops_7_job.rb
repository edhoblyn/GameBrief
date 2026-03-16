class ScrapeCallOfDutyBlackOps7Job < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::CallOfDutyBlackOps7Importer.new.call
    Rails.logger.info(
      "ScrapeCallOfDutyBlackOps7Job: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
