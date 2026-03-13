class ChatsController < ApplicationController
  before_action :set_patch

  def create
    @chat = @patch.chats.find_or_create_by(user: current_user)
    redirect_to patch_path(@patch, chat_id: @chat.id, return_to: safe_return_to_path)
  end

  private

  def set_patch
    @patch = Patch.find(params[:patch_id])
  end

  def safe_return_to_path
    return if params[:return_to].blank?

    return_to = params[:return_to].to_s
    return unless return_to.start_with?("/")
    return if return_to.start_with?("//")

    return_to
  end
end
