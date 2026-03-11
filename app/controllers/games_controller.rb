class GamesController < ApplicationController
  def index
    @games = Game.all
    @games = @games.where("name ILIKE ?", "%#{params[:query]}%") if params[:query].present?
    @games = @games.where("? = ANY(genre::text[])", params[:genre]) if params[:genre].present?
    @games = case params[:sort]
             when "name"     then @games.order(name: :asc)
             when "followed" then @games.left_joins(:favourites).group("games.id").order("COUNT(favourites.id) DESC")
             else @games
             end
  end

  def show
    @game = Game.find(params[:id])
    @patches = @game.patches.order(
      Arel.sql("CASE WHEN source_url IS NULL THEN 1 ELSE 0 END"),
      created_at: :desc
    )
    @events = @game.events.order(start_date: :asc)
    @favourite = current_user.favourites.find_by(game: @game)
  end
end
