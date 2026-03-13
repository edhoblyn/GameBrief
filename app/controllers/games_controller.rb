class GamesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :suggest]
  PATCH_SORT_OPTIONS = %w[newest oldest].freeze

  def index
    load_games_index
    @game_suggestion ||= GameSuggestion.new
  end

  def show
    @game = Game.find(params[:id])
    @patch_date_filter = params[:date_filter].presence_in(Patch::DATE_FILTERS.keys) || "all"
    @patch_sort = params[:sort].presence_in(PATCH_SORT_OPTIONS) || "newest"
    @patches = @game.patches.with_date_filter(@patch_date_filter)
    @patches = apply_patch_sort(@patches)
    @events = @game.events.order(start_date: :asc)
    @favourite = current_user&.favourites&.find_by(game: @game)
    @scrape_source_config = PatchScrapeRunner.config_for_game(@game)
    @followers_count = @game.favourites.count
  end

  def suggest
    @game_suggestion = GameSuggestion.new(game_suggestion_params)

    if @game_suggestion.save
      redirect_to games_path, notice: "Thanks. We have saved your game suggestion."
    else
      load_games_index
      render :index, status: :unprocessable_entity
    end
  end

  private

  def load_games_index
    @games = Game.all
    @games = @games.search_by_name(params[:query])
    @games = @games.with_genre(params[:genre])
    @games = @games.free_to_play_only(params[:free_to_play])
    @games = case params[:sort]
             when "name"     then @games.order(name: :asc)
             when "followed" then @games.left_joins(:favourites).group("games.id").order("COUNT(favourites.id) DESC")
             else @games
             end
    @favourites_by_game_id = current_user&.favourites&.where(game_id: @games.select(:id))&.index_by(&:game_id) || {}
  end

  def game_suggestion_params
    params.require(:game_suggestion).permit(:name)
  end

  def apply_patch_sort(scope)
    case @patch_sort
    when "oldest"
      scope.known_oldest_first
    else
      scope.known_newest_first
    end
  end
end
