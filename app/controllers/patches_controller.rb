class PatchesController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
    @patches = @game.patches
  end

  def show
    @patch = Patch.includes(:patch_summaries, :game).find(params[:id])
  end
end
