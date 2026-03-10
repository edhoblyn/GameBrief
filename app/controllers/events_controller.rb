class EventsController < ApplicationController
  def index
    followed_game_ids = user_signed_in? ? current_user.favourite_games.pluck(:id) : []
    @events = Event.includes(:game)
                   .order(
                     Arel.sql("CASE WHEN game_id IN (#{followed_game_ids.any? ? followed_game_ids.join(',') : 'NULL'}) THEN 0 ELSE 1 END"),
                     start_date: :asc
                   )
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
