class FriendshipsController < ApplicationController
  def create
    friend = User.find(params[:friend_id])

    # Bidirectional: create both sides of the friendship
    friendship = current_user.friendships.create!(friend: friend)
    friend.friendships.create!(friend: current_user)

    render json: { friendship_id: friendship.id }
  end

  def destroy
    friendship = current_user.friendships.find(params[:id])
    friend = friendship.friend

    # Remove both sides
    current_user.friendships.where(friend: friend).destroy_all
    friend.friendships.where(friend: current_user).destroy_all

    head :ok
  end
end
