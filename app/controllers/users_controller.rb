class UsersController < ApplicationController
  before_action :require_admin_for_index!, only: :index

  def index
    @users = User.where.not(id: current_user.id).order(:email)
  end

  def show
    @user = User.find(params[:id])
    @games_count = @user.favourite_games.count
    @reminders_count = @user.reminders.count
  end

  private

  def require_admin_for_index!
    head :forbidden unless current_user&.admin?
  end
end
