require "anthropic"

class EventSummaryService
  PROVIDER_COOLDOWN_KEY = "event_summary_service/anthropic_provider_disabled_until".freeze
  PROVIDER_COOLDOWN = 30.minutes

  class << self
    def provider_temporarily_unavailable?
      disabled_until = provider_disabled_until || Rails.cache.read(PROVIDER_COOLDOWN_KEY)
      disabled_until.present? && disabled_until > Time.current
    end

    def disable_provider_temporarily!(duration: PROVIDER_COOLDOWN)
      disabled_until = Time.current + duration
      self.provider_disabled_until = disabled_until
      Rails.cache.write(PROVIDER_COOLDOWN_KEY, disabled_until, expires_in: duration)
      disabled_until
    end

    def reset_provider_cooldown!
      self.provider_disabled_until = nil
      Rails.cache.delete(PROVIDER_COOLDOWN_KEY)
    end

    private

    attr_accessor :provider_disabled_until
  end

  def initialize(event)
    @event = event
  end

  def call
    return if @event.ai_summary_source.blank?
    return if self.class.provider_temporarily_unavailable?

    client = Anthropic::Client.new

    message = client.messages.create(
      model: :"claude-opus-4-6",
      max_tokens: 256,
      messages: [
        {
          role: "user",
          content: "Write a short 1-2 sentence summary of this gaming event for a casual player. Focus on why it matters and avoid hypey filler.\n\n#{@event.ai_summary_source}"
        }
      ]
    )

    message.content.find { |block| block.type == :text }&.text&.strip
  rescue Anthropic::Errors::BadRequestError => e
    raise unless credits_exhausted?(e)

    self.class.disable_provider_temporarily!
    Rails.logger.warn(
      "EventSummaryService: skipping AI summaries because Anthropic credits are exhausted"
    )
    nil
  end

  private

  def credits_exhausted?(error)
    return false unless error.status == 400

    error_message(error).match?(/credit balance is too low/i)
  end

  def error_message(error)
    body = error.body

    if body.respond_to?(:dig)
      body.dig(:error, :message).to_s.presence ||
        body.dig("error", "message").to_s.presence ||
        error.message.to_s
    else
      error.message.to_s
    end
  end
end
