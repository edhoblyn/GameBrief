class ScrapeClashOfClansJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::ClashOfClansImporter.new.call
    Rails.logger.info(
      "ScrapeClashOfClansJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
