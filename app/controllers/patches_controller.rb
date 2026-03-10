class PatchesController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
    @patches = @game.patches
  end

  def show
    @patch = Patch.includes(:patch_summaries, :game).find(params[:id])
    @summaries_by_type = @patch.patch_summaries.index_by(&:summary_type)
  end

  def generate_summary
    @patch = Patch.find(params[:id])
    summary_type = params[:summary_type].presence || "quick_summary"
    begin
      summary_text = SummaryService.new(@patch, summary_type).call
      @patch.patch_summaries.where(summary_type: summary_type).destroy_all
      @patch.patch_summaries.create!(summary: summary_text, summary_type: summary_type)
      flash[:notice] = "#{SummaryService::LABELS[summary_type]} generated!"
    rescue => e
      flash[:alert] = "Failed to generate summary. Please try again."
    end
    redirect_to patch_path(@patch)
  end
end
