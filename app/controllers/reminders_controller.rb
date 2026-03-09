class RemindersController < ApplicationController
  before_action :authenticate_user!

  def create
    @reminder = current_user.reminders.build(event_id: params[:event_id])
    @reminder.save
    redirect_back fallback_location: root_path
  end

  def destroy
    @reminder = current_user.reminders.find(params[:id])
    @reminder.destroy
    redirect_back fallback_location: root_path
  end
end
