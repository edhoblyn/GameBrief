class Admin::PatchScrapesController < Admin::BaseController

  def create
    result = PatchScrapeRunner.run(params.require(:source))
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
    diagnostics = PatchScrapeRunner.run_all_with_diagnostics
    store_scrape_logs(diagnostics)
    failures = diagnostics.count { |entry| !entry.success }
    imported = diagnostics.sum(&:imported)
    skipped = diagnostics.sum(&:skipped)

    message = if failures.zero?
      "All scrapes finished: #{imported} imported, #{skipped} skipped."
    else
      "All scrapes finished with #{failures} failure#{'s' unless failures == 1}: #{imported} imported, #{skipped} skipped."
    end

    redirect_to admin_dashboard_path, notice: message
  end

  private

  def store_scrape_logs(diagnostics)
    session[:admin_scrape_logs] = diagnostics.map do |entry|
      {
        "source" => entry.source,
        "label" => entry.label,
        "imported" => entry.imported,
        "skipped" => entry.skipped,
        "success" => entry.success,
        "error_message" => entry.error_message,
        "timestamp" => entry.timestamp.iso8601
      }
    end
  end

  def scrape_http_error_message(error)
    config = PatchScrapeRunner.fetch(params[:source])

    if error.io.status.first == "403" && params[:source].to_s == "fortnite"
      "#{config[:label]} scrape is currently blocked by the official source site (403 Forbidden). Fortnite news is behind bot protection right now."
    else
      "#{config[:label]} scrape failed: #{error.message}"
    end
  rescue KeyError
    "Scrape failed: #{error.message}"
  end
end
