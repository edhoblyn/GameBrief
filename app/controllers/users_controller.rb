class UsersController < ApplicationController
  def index
    @users = User.where.not(id: current_user.id).order(:email)
  end

  def show
    @user = User.find(params[:id])
    @games_count = @user.favourite_games.count
    @reminders_count = @user.reminders.count
  end
end
