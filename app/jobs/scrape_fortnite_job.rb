class ScrapeFortniteJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::FortniteImporter.new.call
    Rails.logger.info(
      "ScrapeFortniteJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
