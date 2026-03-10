class ChatsController < ApplicationController
  before_action :set_patch

  def create
    @chat = @patch.chats.find_or_create_by(user: current_user)
    redirect_to patch_path(@patch, chat_id: @chat.id)
  end

  private

  def set_patch
    @patch = Patch.find(params[:patch_id])
  end
end
