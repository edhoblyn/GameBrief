class Admin::DashboardController < Admin::BaseController
  def show
    @scrape_sources = PatchScrapeRunner.sources.map do |source|
      config = PatchScrapeRunner.fetch(source)

      {
        source: source,
        label: config[:label],
        game_slugs: config.fetch(:game_slugs, [])
      }
    end
  end
end
