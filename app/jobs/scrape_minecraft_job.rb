class ScrapeMinecraftJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::MinecraftImporter.new.call
    Rails.logger.info(
      "ScrapeMinecraftJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
