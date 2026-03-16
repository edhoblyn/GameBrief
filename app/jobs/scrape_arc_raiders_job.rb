class ScrapeArcRaidersJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::ArcRaidersImporter.new.call
    Rails.logger.info(
      "ScrapeArcRaidersJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
