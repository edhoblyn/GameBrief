class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @featured_gamers = User.where.not(username: nil).order(follower_count: :desc).limit(4)
  end

  def find_friends
    @users = User.where.not(id: current_user.id)
    if params[:q].present?
      @users = @users.where("username ILIKE :q OR email ILIKE :q", q: "%#{params[:q]}%")
    end
    @users = @users.order(:username, :email)
  end

  def my_profile
    @followed_games = current_user.favourite_games
    @reminders = current_user.reminders.includes(event: :game).order("events.start_date asc")
    @recent_patches = Patch.where(game: @followed_games)
                           .recent_first
                           .limit(10)
                           .includes(:game)
  end
end
