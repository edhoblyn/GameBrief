class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :add_nav_data

  private

  def add_nav_data
    return unless current_user

    @reminders = current_user.reminders.includes(event: :game).order("events.start_date asc")
    @followed_games = current_user.favourite_games
    @recent_patches = Patch.where(game: @followed_games)
                           .recent_first
                           .limit(10)
                           .includes(:game)
  end
end
