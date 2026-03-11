class ScrapeDestiny2Job < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::Destiny2Importer.new.call
    Rails.logger.info(
      "ScrapeDestiny2Job: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
