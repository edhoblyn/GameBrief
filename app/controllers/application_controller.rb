class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :add_nav_data
  before_action :configure_permitted_parameters, if: :devise_controller?

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

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :avatar_url, :bio, :avatar_image, :cover_image])
  end

  def safe_return_to_path
    return if params[:return_to].blank?

    return_to = params[:return_to].to_s
    return unless return_to.start_with?("/")
    return if return_to.start_with?("//")

    return_to
  end
end
