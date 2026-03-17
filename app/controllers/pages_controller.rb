class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @trending_games = Game.joins(:patches)
                          .group(:id)
                          .order(Arel.sql("COUNT(patches.id) DESC, games.name ASC"))
                          .limit(12)
  end

  def find_friends
    @pending_requests = current_user.received_requests.includes(:user)
    @users = params[:friends_only].present? ? current_user.friends : User.where.not(id: current_user.id)
    @users = @users.where("username ILIKE :q OR email ILIKE :q", q: "#{params[:q]}%") if params[:q].present?
    @users = @users.order(:username, :email)

    respond_to do |format|
      format.html
      format.json do
        user_ids    = @users.map(&:id)
        sent_map    = current_user.friendships.where(friend_id: user_ids).index_by(&:friend_id)
        received_map = Friendship.where(friend_id: current_user.id, user_id: user_ids).index_by(&:user_id)

        render json: @users.map { |u|
          sent     = sent_map[u.id]
          received = received_map[u.id]
          {
            id:                  u.id,
            display:             u.username.presence || u.email,
            email:               u.username.present? ? u.email : nil,
            initial:             (u.username.presence || u.email).first.upcase,
            is_friend:           sent&.status == "accepted",
            friendship_id:       sent&.id,
            pending_sent:        sent&.status == "pending",
            pending_received:    received&.status == "pending",
            incoming_request_id: (received&.status == "pending") ? received.id : nil
          }
        }
      end
    end
  end

  def my_profile
    @pending_requests = current_user.received_requests.includes(:user)
    @pending_received_count = @pending_requests.count
    @friends = current_user.friends
    feed_user_ids = [current_user.id] + current_user.friend_ids
    @feed_posts = Post.where(user_id: feed_user_ids)
                      .left_joins(:likes)
                      .group(:id)
                      .order(Arel.sql("EXTRACT(EPOCH FROM posts.created_at) + COUNT(likes.id) * 3600 DESC"))
    @friends = current_user.friends
    @games = @followed_games.order(:name)
    @favourites_by_game_id = current_user.favourites.index_by(&:game_id)
  end

  def my_games
    @games = @followed_games.order(:name)
    @favourites_by_game_id = current_user.favourites.index_by(&:game_id)
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
  end

  def my_events
    @sort = params[:sort].presence_in(%w[upcoming latest]) || "upcoming"
    @view = params[:view].presence_in(%w[grouped]) || "flat"

    @events = @sort == "latest" ? @reminders.reorder("events.start_date desc") : @reminders
  end
end
