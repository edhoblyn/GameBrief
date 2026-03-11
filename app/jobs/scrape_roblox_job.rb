class ScrapeRobloxJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::RobloxImporter.new.call
    Rails.logger.info(
      "ScrapeRobloxJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
