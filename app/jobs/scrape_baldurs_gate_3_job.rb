class ScrapeBaldursGate3Job < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::BaldursGate3Importer.new.call
    Rails.logger.info(
      "ScrapeBaldursGate3Job: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
