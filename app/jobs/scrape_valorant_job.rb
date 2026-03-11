class ScrapeValorantJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::ValorantImporter.new.call
    Rails.logger.info(
      "ScrapeValorantJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
