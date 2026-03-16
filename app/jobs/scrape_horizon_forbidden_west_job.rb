class ScrapeHorizonForbiddenWestJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::HorizonForbiddenWestImporter.new.call
    Rails.logger.info(
      "ScrapeHorizonForbiddenWestJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
