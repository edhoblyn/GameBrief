class FriendshipsController < ApplicationController
  def create
    friend = User.find(params[:friend_id])

    # Guard: don't create if a record already exists in either direction
    existing = Friendship.find_by(user: current_user, friend: friend) ||
               Friendship.find_by(user: friend, friend: current_user)

    if existing
      return render json: { error: "already exists" }, status: :unprocessable_entity
    end

    friendship = Friendship.create!(user: current_user, friend: friend, status: "pending")
    render json: { friendship_id: friendship.id, status: "pending" }
  end

  def update
    # Only the recipient can accept
    friendship = Friendship.find_by!(id: params[:id], friend: current_user, status: "pending")
    friendship.update!(status: "accepted")
    reverse = Friendship.create!(user: current_user, friend: friendship.user, status: "accepted")

    render json: { friendship_id: reverse.id, status: "accepted" }
  end

  def destroy
    # Allow either party to cancel/decline/unfriend
    friendship = Friendship.where(id: params[:id])
                           .where("user_id = ? OR friend_id = ?", current_user.id, current_user.id)
                           .first

    return head :not_found unless friendship

    other = friendship.user == current_user ? friendship.friend : friendship.user

    # Remove both sides (unfriend) or just this record (cancel/decline a pending request)
    Friendship.where(user: current_user, friend: other).destroy_all
    Friendship.where(user: other, friend: current_user).destroy_all

    head :ok
  end
end
