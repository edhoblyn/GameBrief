class ScrapeSpiderMan2Job < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::SpiderMan2Importer.new.call
    Rails.logger.info(
      "ScrapeSpiderMan2Job: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
