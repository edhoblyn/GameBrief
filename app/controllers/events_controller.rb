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
    @selected_game_ids = selected_game_ids

    upcoming_events = Event.includes(:game).where("start_date >= ?", now.beginning_of_day)
    @game_filter_options = Game.joins(:events)
                               .merge(upcoming_events)
                               .distinct
                               .to_a
                               .sort_by { |game| [@followed_game_ids.include?(game.id) ? 0 : 1, game.name.downcase] }

    @summary_cards = [
      { label: "Upcoming events", value: upcoming_events.count },
      { label: "From followed games", value: @followed_game_ids.any? ? upcoming_events.where(game_id: @followed_game_ids).count : 0 },
      { label: "Happening this week", value: upcoming_events.where(start_date: now.beginning_of_day..today.end_of_week.end_of_day).count }
    ]

    filtered_events = apply_time_filter(upcoming_events, now, today)
    filtered_events = apply_game_filter(filtered_events)
    @events = order_events(filtered_events)
    @event_groups = @events.group_by { |event| timeline_group_for(event.start_date.to_date, today) }.to_a
  end

  def show
    @event = Event.includes(:game).find(params[:id])
    @reminder = current_user.reminders.find_by(event: @event)
    @favourite = current_user.favourites.find_by(game: @event.game)

    now = Time.zone.now
    @event_status = event_status_for(@event.start_date, now)
    @countdown_label = countdown_label_for(@event.start_date, now)
    @related_events = @event.game.events
                           .where.not(id: @event.id)
                           .where("start_date >= ?", now.beginning_of_day)
                           .order(start_date: :asc)
                           .limit(3)
    @latest_patch = @event.game.patches.known_newest_first.first
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

  def apply_game_filter(scope)
    return scope if @selected_game_ids.empty?

    scope.where(game_id: @selected_game_ids)
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

  def selected_game_ids
    Array(params[:game_ids]).filter_map do |game_id|
      Integer(game_id, exception: false)
    end.uniq
  end

  def event_status_for(start_date, now)
    event_date = start_date.to_date
    today = now.to_date

    if event_date < today
      { label: "Past event", tone: "past" }
    elsif event_date == today
      { label: "Happening today", tone: "live" }
    elsif event_date <= today.end_of_week
      { label: "This week", tone: "soon" }
    else
      { label: "Upcoming", tone: "upcoming" }
    end
  end

  def countdown_label_for(start_date, now)
    distance = ActionController::Base.helpers.distance_of_time_in_words(now, start_date)

    if start_date < now
      "Started #{distance} ago"
    else
      "Starts in #{distance}"
    end
  end
end
