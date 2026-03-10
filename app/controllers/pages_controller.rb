class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @featured_gamers = User.where.not(username: nil).order(follower_count: :desc).limit(4)
  end

  def dashboard
    @followed_games = current_user.favourite_games
    @reminders = current_user.reminders.includes(event: :game).order("events.start_date asc")
  end
end
