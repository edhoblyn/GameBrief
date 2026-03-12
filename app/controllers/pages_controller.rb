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

  def my_games
    @games = current_user.favourite_games.order(:name)
  end

  def my_patches
    @followed_games = current_user.favourite_games
    @date_filter = params[:date_filter].presence_in(Patch::DATE_FILTERS.keys) || "all"
    @sort = params[:sort].presence_in(%w[newest oldest]) || "newest"

    @patches = Patch.where(game: @followed_games)
                    .includes(:game)
                    .with_date_filter(@date_filter)

    @patches = case @sort
               when "oldest" then @patches.known_oldest_first
               else @patches.known_newest_first
               end
  end
end
