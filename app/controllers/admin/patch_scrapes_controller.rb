class Admin::PatchScrapesController < Admin::BaseController

  def create
    result = PatchScrapeRunner.run(params.require(:source))

    redirect_back(
      fallback_location: games_path,
      notice: "#{result.label} scrape finished: #{result.imported} imported, #{result.skipped} skipped."
    )
  rescue KeyError
    redirect_back(fallback_location: games_path, alert: "Unknown scrape source.")
  rescue ActiveRecord::RecordNotFound
    config = PatchScrapeRunner.fetch(params[:source])
    redirect_back(fallback_location: games_path, alert: "#{config[:missing_game_error]} #{config[:missing_game_hint]}")
  rescue OpenURI::HTTPError => e
    redirect_back(fallback_location: games_path, alert: scrape_http_error_message(e))
  end

  private

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
