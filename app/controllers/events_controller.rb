class EventsController < ApplicationController
  def index
    @events = Event.order(start_date: :asc)
  end

  def show
    @event = Event.find(params[:id])
  end
end
