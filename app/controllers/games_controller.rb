class GamesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

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
    @patches = @game.patches.known_newest_first
    @events = @game.events.order(start_date: :asc)
    @favourite = current_user&.favourites&.find_by(game: @game)
    @scrape_source_config = PatchScrapeRunner.config_for_game(@game)
  end
end
