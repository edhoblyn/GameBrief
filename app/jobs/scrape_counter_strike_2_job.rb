class ScrapeCounterStrike2Job < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::CounterStrike2Importer.new.call
    Rails.logger.info(
      "ScrapeCounterStrike2Job: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
