class PatchesController < ApplicationController
  def index
    if params[:game_id]
      @game = Game.find(params[:game_id])
      @patches = @game.patches
    else
      followed_game_ids = user_signed_in? ? current_user.favourite_games.pluck(:id) : []
      @patches = Patch.includes(:game)
                      .order(
                        Arel.sql("CASE WHEN game_id IN (#{followed_game_ids.any? ? followed_game_ids.join(',') : 'NULL'}) THEN 0 ELSE 1 END"),
                        created_at: :desc
                      )
    end
  end

  def show
    @patch = Patch.includes(:patch_summaries, :game).find(params[:id])
    @summaries_by_type = @patch.patch_summaries.index_by(&:summary_type)
    if user_signed_in?
      @chat = @patch.chats.find_by(user: current_user, id: params[:chat_id]) ||
              @patch.chats.find_or_create_by(user: current_user)
    end
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
