class ScrapeLeagueOfLegendsJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::LeagueOfLegendsImporter.new.call
    Rails.logger.info(
      "ScrapeLeagueOfLegendsJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
