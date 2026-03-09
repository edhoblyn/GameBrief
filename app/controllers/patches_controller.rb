class PatchesController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
    @patches = @game.patches
  end

  def show
    @patch = Patch.includes(:patch_summaries, :game).find(params[:id])
  end

  def generate_summary
    @patch = Patch.find(params[:id])
    begin
      summary_text = SummaryService.new(@patch).call
      @patch.patch_summaries.create!(summary: summary_text)
      flash[:notice] = "Summary generated!"
    rescue => e
      flash[:alert] = "Failed to generate summary. Please try again."
    end
    redirect_to patch_path(@patch)
  end
end
