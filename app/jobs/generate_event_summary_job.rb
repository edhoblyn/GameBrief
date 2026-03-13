class GenerateEventSummaryJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return if event.nil?
    return if event.summary.present?
    return unless event.ai_summarizable?

    summary = EventSummaryService.new(event).call
    if summary.blank?
      event.update_column(:summary_requested_at, nil)
      return
    end

    event.update!(summary: summary)
  rescue StandardError
    event&.update_column(:summary_requested_at, nil)
    raise
  end
end
