class GenerateEventSummaryJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return if event.nil?
    return if event.summary.present?
    return unless event.ai_summarizable?

    summary = EventSummaryService.new(event).call
    if summary.blank?
      clear_summary_request(event)
      return
    end

    event.update!(summary: summary)
  rescue StandardError
    clear_summary_request(event)
    raise
  end

  private

  def clear_summary_request(event)
    return unless event&.has_attribute?(:summary_requested_at)

    event.update_column(:summary_requested_at, nil)
  end
end
