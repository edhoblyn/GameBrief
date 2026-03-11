class ScrapeMarvelRivalsJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::MarvelRivalsImporter.new.call
    Rails.logger.info(
      "ScrapeMarvelRivalsJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
