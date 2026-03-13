class FavouritesController < ApplicationController
  before_action :authenticate_user!

  def create
    @game = Game.find(params[:game_id])
    @favourite = current_user.favourites.find_or_create_by(game_id: params[:game_id])
    flash[:success] = "#{@game.name} has been added to your favourites!"
    redirect_back fallback_location: root_path
  end

  def destroy
    @favourite = current_user.favourites.find(params[:id])
    @favourite.destroy
    flash[:danger] = "Game removed from your favourites."
    redirect_back fallback_location: root_path
  end
end
