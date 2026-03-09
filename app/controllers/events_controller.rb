class EventsController < ApplicationController
  def index
    @events = Event.order(start_date: :asc)
  end

  def show
    @event = Event.find(params[:id])
    @reminder = current_user.reminders.find_by(event: @event)
  end
end
