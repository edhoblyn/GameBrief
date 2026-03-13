class Event < ApplicationRecord
  belongs_to :game

  after_commit :request_ai_summary_later, on: [:create, :update], if: :saved_change_requiring_ai_summary?

  def ai_summary_source
    [title, description].compact.join("\n").strip
  end

  def ai_summarizable?
    ai_summary_source.length >= 80
  end

  def request_ai_summary!
    return false if summary.present?
    return false unless ai_summarizable?
    return false if ai_summary_pending?

    update_columns(summary_requested_at: Time.current)
    GenerateEventSummaryJob.perform_later(id)
    true
  end

  def ai_summary_pending?
    summary_requested_at.present? && summary_requested_at >= updated_at
  end

  private

  def saved_change_requiring_ai_summary?
    summary.blank? && ai_summarizable? && (saved_change_to_title? || saved_change_to_description?)
  end

  def request_ai_summary_later
    request_ai_summary!
  end
end
