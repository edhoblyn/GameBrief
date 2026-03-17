class UsersController < ApplicationController
  before_action :require_admin_for_index!, only: :index
  skip_before_action :authenticate_user!, only: [:show, :card]

  def index
    @users = User.where.not(id: current_user.id).order(:email)
  end

  def show
    @user            = User.find(params[:id])
    @favourite_games = @user.favourite_games.order(:name)
    @friends         = @user.friends.limit(20)
    @friends_count   = @user.friends.count
    @posts_count     = @user.posts.count
    @games_count     = @favourite_games.count
    @posts           = user_signed_in? ? @user.posts.order(created_at: :desc).limit(20) : []

    if user_signed_in? && current_user != @user
      @existing_friendship = current_user.friendships.find_by(friend: @user)
      @incoming_request    = Friendship.find_by(user: @user, friend: current_user, status: "pending")
    end
  end

  def card
    @user            = User.find(params[:id])
    @favourite_games = @user.favourite_games.order(:name)
    @friends         = @user.friends.limit(20)
    @friends_count   = @user.friends.count
    @posts_count     = @user.posts.count
    @games_count     = @favourite_games.count
    @posts           = @user.posts.order(created_at: :desc).limit(20)

    if user_signed_in? && current_user != @user
      @existing_friendship = current_user.friendships.find_by(friend: @user)
      @incoming_request    = Friendship.find_by(user: @user, friend: current_user, status: "pending")
    end

    render layout: false
  end

  private

  def require_admin_for_index!
    head :forbidden unless current_user&.admin?
  end
end
