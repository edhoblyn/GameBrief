class Admin::PatchScrapesController < Admin::BaseController

  def create
    source = params.require(:source)
    config = PatchScrapeRunner.fetch(source)

    unless PatchScrapeRunner.manual_trigger_enabled?(source)
      redirect_back(
        fallback_location: admin_dashboard_path,
        alert: config[:disabled_message] || "#{config[:label]} currently requires an API or alternate endpoint."
      )
      return
    end

    result = PatchScrapeRunner.run(source)
    store_scrape_logs([PatchScrapeRunner.diagnostic_for_result(result)])

    redirect_back(
      fallback_location: admin_dashboard_path,
      notice: "#{result.label} scrape finished: #{result.imported} imported, #{result.skipped} skipped."
    )
  rescue KeyError
    redirect_back(fallback_location: admin_dashboard_path, alert: "Unknown scrape source.")
  rescue ActiveRecord::RecordNotFound => e
    config = PatchScrapeRunner.fetch(params[:source])
    store_scrape_logs([PatchScrapeRunner.diagnostic_for_error(params[:source], e)])
    redirect_back(fallback_location: admin_dashboard_path, alert: "#{config[:missing_game_error]} #{config[:missing_game_hint]}")
  rescue OpenURI::HTTPError => e
    store_scrape_logs([PatchScrapeRunner.diagnostic_for_error(params[:source], e)])
    redirect_back(fallback_location: admin_dashboard_path, alert: scrape_http_error_message(e))
  rescue StandardError => e
    store_scrape_logs([PatchScrapeRunner.diagnostic_for_error(params[:source], e)])
    redirect_back(fallback_location: admin_dashboard_path, alert: "Scrape failed: #{e.message}")
  end

  def run_all
    AdminPatchScrapeLogStore.mark_running(current_user)
    RunAllPatchScrapesJob.perform_later(current_user.id)

    redirect_to admin_dashboard_path, notice: "All scrapes started in the background. Refresh shortly for the latest run output."
  end

  private

  def store_scrape_logs(diagnostics)
    AdminPatchScrapeLogStore.store_diagnostics(current_user, diagnostics)
  end

  def scrape_http_error_message(error)
    config = PatchScrapeRunner.fetch(params[:source])

    if error.io.status.first == "403" && config[:disabled_message].present?
      config[:disabled_message]
    else
      "#{config[:label]} scrape failed: #{error.message}"
    end
  rescue KeyError
    "Scrape failed: #{error.message}"
  end
end
