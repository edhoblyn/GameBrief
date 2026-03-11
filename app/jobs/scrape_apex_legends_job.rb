class ScrapeApexLegendsJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::ApexLegendsImporter.new.call
    Rails.logger.info(
      "ScrapeApexLegendsJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
