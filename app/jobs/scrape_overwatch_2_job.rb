class ScrapeOverwatch2Job < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::Overwatch2Importer.new.call
    Rails.logger.info(
      "ScrapeOverwatch2Job: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
