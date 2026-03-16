class ScrapeCyberpunk2077Job < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::Cyberpunk2077Importer.new.call
    Rails.logger.info(
      "ScrapeCyberpunk2077Job: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
