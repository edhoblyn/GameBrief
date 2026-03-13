class EventsController < ApplicationController
  TIME_FILTERS = {
    "all" => "All upcoming",
    "week" => "This week",
    "month" => "This month",
    "future" => "Future"
  }.freeze

  def index
    now = Time.zone.now
    today = now.to_date
    @followed_game_ids = user_signed_in? ? current_user.favourite_games.pluck(:id) : []
    @time_filter = TIME_FILTERS.key?(params[:time_filter]) ? params[:time_filter] : "all"

    upcoming_events = Event.includes(:game).where("start_date >= ?", now.beginning_of_day)

    @summary_cards = [
      { label: "Upcoming events", value: upcoming_events.count },
      { label: "From followed games", value: @followed_game_ids.any? ? upcoming_events.where(game_id: @followed_game_ids).count : 0 },
      { label: "Happening this week", value: upcoming_events.where(start_date: now.beginning_of_day..today.end_of_week.end_of_day).count }
    ]

    filtered_events = apply_time_filter(upcoming_events, now, today)
    @events = order_events(filtered_events)
    @event_groups = @events.group_by { |event| timeline_group_for(event.start_date.to_date, today) }.to_a
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

  private

  def apply_time_filter(scope, now, today)
    case @time_filter
    when "week"
      scope.where(start_date: now.beginning_of_day..today.end_of_week.end_of_day)
    when "month"
      scope.where(start_date: now.beginning_of_day..today.end_of_month.end_of_day)
    when "future"
      scope.where("start_date > ?", today.end_of_month.end_of_day)
    else
      scope
    end
  end

  def order_events(scope)
    if @followed_game_ids.any?
      scope.order(
        Arel.sql("CASE WHEN game_id IN (#{@followed_game_ids.join(',')}) THEN 0 ELSE 1 END"),
        start_date: :asc
      )
    else
      scope.order(start_date: :asc)
    end
  end

  def timeline_group_for(date, today)
    if date == today
      "Today"
    elsif date <= today.end_of_week
      "Later This Week"
    elsif date <= today.end_of_month
      "This Month"
    else
      "Later"
    end
  end
end
