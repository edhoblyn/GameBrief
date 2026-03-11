class Admin::PatchScrapesController < ApplicationController
  before_action :require_admin!

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
  end

  private

  def require_admin!
    head :forbidden unless current_user&.admin?
  end
end
