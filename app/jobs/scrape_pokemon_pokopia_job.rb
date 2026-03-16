class ScrapePokemonPokopiaJob < ApplicationJob
  queue_as :default

  def perform
    result = PatchImporters::PokemonPokopiaImporter.new.call
    Rails.logger.info(
      "ScrapePokemonPokopiaJob: imported=#{result.imported} skipped=#{result.skipped}"
    )
  end
end
