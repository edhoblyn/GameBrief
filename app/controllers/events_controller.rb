class EventsController < ApplicationController
  def index
    @events = Event.order(start_date: :asc)
  end

  def show
    @event = Event.find(params[:id])
    @reminder = current_user.reminders.find_by(event: @event)
  end

  def generate_summary
    @event = Event.find(params[:id])
    begin
      @event.update!(summary: EventSummaryService.new(@event).call)
      flash[:notice] = "Event summary generated!"
    rescue => e
      flash[:alert] = "Failed to generate summary. Please try again."
    end
    redirect_to event_path(@event)
  end
end
