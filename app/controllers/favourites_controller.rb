class FavouritesController < ApplicationController
  before_action :authenticate_user!

  def create
    @favourite = current_user.favourites.find_or_create_by(game_id: params[:game_id])
    flash[:notice] = "Game added to your favourites!"
    redirect_back fallback_location: root_path
  end

  def destroy
    @favourite = current_user.favourites.find(params[:id])
    @favourite.destroy
    flash[:notice] = "Game removed from your favourites."
    redirect_back fallback_location: root_path
  end
end
