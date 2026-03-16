class ScrapeBattlefield6Job < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::Battlefield6Importer.new.call
    Rails.logger.info(
      "ScrapeBattlefield6Job: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
