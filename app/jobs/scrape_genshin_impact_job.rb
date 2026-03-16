class ScrapeGenshinImpactJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::GenshinImpactImporter.new.call
    Rails.logger.info(
      "ScrapeGenshinImpactJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
