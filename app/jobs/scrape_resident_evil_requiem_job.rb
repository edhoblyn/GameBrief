class ScrapeResidentEvilRequiemJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::ResidentEvilRequiemImporter.new.call
    Rails.logger.info(
      "ScrapeResidentEvilRequiemJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
