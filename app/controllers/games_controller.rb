class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def show
    @game = Game.find(params[:id])
    @events = @game.events.order(start_date: :asc)
    @favourite = current_user.favourites.find_by(game: @game)
  end
end
