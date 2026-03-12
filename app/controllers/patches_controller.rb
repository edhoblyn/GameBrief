class PatchesController < ApplicationController
  SORT_OPTIONS = %w[recommended newest oldest].freeze

  def index
    @date_filter = params[:date_filter].presence_in(Patch::DATE_FILTERS.keys) || "all"
    @sort = params[:sort].presence_in(SORT_OPTIONS) || "recommended"
    @games = Game.order(:name)

    if params[:game_id]
      @game = Game.find(params[:game_id])
      @patches = @game.patches
                      .includes(:game)
                      .with_date_filter(@date_filter)
      @patches = apply_sort(@patches)
    else
      followed_game_ids = user_signed_in? ? current_user.favourite_games.pluck(:id) : []
      @patches = Patch.includes(:game)
                      .with_date_filter(@date_filter)
      @patches = apply_game_filter(@patches)
      @patches = apply_sort(@patches, followed_game_ids: followed_game_ids)
    end
  end

  def show
    @patch = Patch.includes(:patch_summaries, :game).find(params[:id])
    @summaries_by_type = @patch.patch_summaries.index_by(&:summary_type)
    @back_to_patches_path = safe_return_to_path || game_patches_path(@patch.game)
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
    redirect_to patch_path(@patch, return_to: safe_return_to_path)
  end

  private

  def safe_return_to_path
    return if params[:return_to].blank?

    return_to = params[:return_to].to_s
    return unless return_to.start_with?("/")
    return if return_to.start_with?("//")

    return_to
  end

  def apply_game_filter(scope)
    return scope if params[:game].blank?

    scope.where(game_id: @games.where(id: params[:game]).select(:id))
  end

  def apply_sort(scope, followed_game_ids: [])
    case @sort
    when "newest"
      scope.known_newest_first
    when "oldest"
      scope.known_oldest_first
    else
      if followed_game_ids.any?
        followed_first_sql = Patch.sanitize_sql_array(
          ["CASE WHEN game_id IN (?) THEN 0 ELSE 1 END", followed_game_ids]
        )
        scope.order(Arel.sql(followed_first_sql), Arel.sql("#{Patch.effective_published_at_sql} DESC"))
      else
        scope.recent_first
      end
    end
  end
end
