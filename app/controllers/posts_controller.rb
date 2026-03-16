class PostsController < ApplicationController
  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_back fallback_location: root_path
    else
      redirect_back fallback_location: root_path, alert: @post.errors.full_messages.to_sentence
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy
    redirect_back fallback_location: root_path
  end

  private

  def post_params
    params.require(:post).permit(:body)
  end
end
