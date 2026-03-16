class Admin::ChatHistoriesController < Admin::BaseController
  def destroy
    chat_count = Chat.count
    message_count = Message.count

    ActiveRecord::Base.transaction do
      Message.delete_all
      Chat.delete_all
    end

    redirect_to admin_dashboard_path,
                notice: "AI chat history cleared: #{chat_count} chats and #{message_count} messages removed."
  end
end
