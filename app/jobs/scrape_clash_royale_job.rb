class ScrapeClashRoyaleJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::ClashRoyaleImporter.new.call
    Rails.logger.info(
      "ScrapeClashRoyaleJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
