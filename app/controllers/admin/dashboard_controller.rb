class Admin::DashboardController < Admin::BaseController
  def show
    @scrape_sources = PatchScrapeRunner.sources.map do |source|
      config = PatchScrapeRunner.fetch(source)

      {
        source: source,
        label: config[:label],
        game_slugs: config.fetch(:game_slugs, []),
        manual_trigger_enabled: config.fetch(:manual_trigger_enabled, true)
      }
    end
    @admins = User.admins.order(Arel.sql("COALESCE(NULLIF(username, ''), email) ASC"))
    @chat_count = Chat.count
    @message_count = Message.count
    @latest_scrape_run = AdminPatchScrapeLogStore.fetch(current_user)
    @scrape_logs = Array(@latest_scrape_run["logs"])
    @scrape_log_status = @latest_scrape_run["status"]
  end
end
