class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @featured_gamers = User.where.not(username: nil).order(follower_count: :desc).limit(4)
  end

  def my_profile
    @followed_games = current_user.favourite_games
    @reminders = current_user.reminders.includes(event: :game).order("events.start_date asc")
    @recent_patches = Patch.where(game: @followed_games)
                           .order(created_at: :desc)
                           .limit(10)
                           .includes(:game)
  end
end
