class GamesController < ApplicationController
  def index
    if params[:query].present?
      @games = Game.where("name ILIKE ?", "%#{params[:query]}%")
    else
      @games = Game.all
    end
  end

  def show
    @game = Game.find(params[:id])
    @events = @game.events.order(start_date: :asc)
    @favourite = current_user.favourites.find_by(game: @game)
  end
end
