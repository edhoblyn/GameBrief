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
    @admins = User.admins.order(Arel.sql("COALESCE(NULLIF(username, ''), email) ASC"))
    @scrape_logs = Array(session[:admin_scrape_logs])
  end
end
