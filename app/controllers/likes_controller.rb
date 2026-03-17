class LikesController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    current_user.likes.find_or_create_by(post: post)
    redirect_back fallback_location: my_profile_path
  end

  def destroy
    like = current_user.likes.find(params[:id])
    like.destroy
    redirect_back fallback_location: my_profile_path
  end
end
