class GamesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  PATCH_SORT_OPTIONS = %w[newest oldest].freeze

  def index
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

  private

  def apply_patch_sort(scope)
    case @patch_sort
    when "oldest"
      scope.known_oldest_first
    else
      scope.known_newest_first
    end
  end
end
