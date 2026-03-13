class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @featured_gamers = User.where.not(username: nil).order(follower_count: :desc).limit(4)
  end

  def find_friends
    @users = User.where.not(id: current_user.id)
    @users = @users.where("username ILIKE :q OR email ILIKE :q", q: "#{params[:q]}%") if params[:q].present?
    @users = @users.order(:username, :email)

    respond_to do |format|
      format.html
      format.json do
        friendship_map = current_user.friendships
                                     .where(friend_id: @users.map(&:id))
                                     .index_by(&:friend_id)
        render json: @users.map { |u|
          friendship = friendship_map[u.id]
          { id: u.id,
            display: u.username.presence || u.email,
            email: u.username.present? ? u.email : nil,
            initial: (u.username.presence || u.email).first.upcase,
            is_friend: friendship.present?,
            friendship_id: friendship&.id }
        }
      end
    end
  end

  def my_profile
    @recent_patches = Patch.where(game: @followed_games)
                           .recent_first
                           .limit(10)
                           .includes(:game)
  end

  def my_games
    @games = @followed_games.order(:name)
  end

  def my_patches
    @date_filter = params[:date_filter].presence_in(Patch::DATE_FILTERS.keys) || "all"
    @sort = params[:sort].presence_in(%w[newest oldest]) || "newest"

    @patches = Patch.where(game: @followed_games)
                    .includes(:game)
                    .with_date_filter(@date_filter)

    @patches = case @sort
               when "oldest" then @patches.known_oldest_first
               else @patches.known_newest_first
               end
    @recent_patches = Patch.where(game: @followed_games)
                           .recent_first
                           .limit(10)
                           .includes(:game)
  end

  def my_events
    @events = current_user.reminders
                          .includes(event: :game)
                          .order("events.start_date asc")
  end
end
