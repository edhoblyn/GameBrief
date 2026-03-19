class PostsController < ApplicationController
  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      (current_user.friends.to_a + [current_user]).each do |user|
        Turbo::StreamsChannel.broadcast_prepend_to(
          "feed_#{user.id}",
          target: "posts",
          partial: "posts/post",
          locals: { post: @post, viewer: user }
        )
      end
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
