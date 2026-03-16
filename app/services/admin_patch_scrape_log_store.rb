class AdminPatchScrapeLogStore
  CACHE_TTL = 12.hours

  class << self
    def fetch(user_or_id)
      store.read(cache_key(user_or_id)) || default_payload
    end

    def mark_running(user_or_id)
      write_payload(
        user_or_id,
        {
          "status" => "running",
          "logs" => [],
          "updated_at" => Time.current.iso8601
        }
      )
    end

    def store_diagnostics(user_or_id, diagnostics)
      write_payload(
        user_or_id,
        {
          "status" => "completed",
          "logs" => serialize(diagnostics),
          "updated_at" => Time.current.iso8601
        }
      )
    end

    def store_failure(user_or_id, error)
      write_payload(
        user_or_id,
        {
          "status" => "failed",
          "logs" => [
            {
              "source" => "run_all",
              "label" => "Run all scrapes",
              "imported" => 0,
              "skipped" => 0,
              "success" => false,
              "error_message" => error.message,
              "timestamp" => Time.current.iso8601
            }
          ],
          "updated_at" => Time.current.iso8601
        }
      )
    end

    def clear(user_or_id)
      store.delete(cache_key(user_or_id))
    end

    private

    def serialize(diagnostics)
      diagnostics.map do |entry|
        {
          "source" => entry.source,
          "label" => entry.label,
          "imported" => entry.imported,
          "skipped" => entry.skipped,
          "success" => entry.success,
          "error_message" => entry.error_message,
          "timestamp" => entry.timestamp.iso8601
        }
      end
    end

    def write_payload(user_or_id, payload)
      store.write(cache_key(user_or_id), payload, expires_in: CACHE_TTL)
    end

    def cache_key(user_or_id)
      "admin_patch_scrape_logs:#{extract_user_id(user_or_id)}"
    end

    def extract_user_id(user_or_id)
      user_or_id.respond_to?(:id) ? user_or_id.id : user_or_id
    end

    def default_payload
      {
        "status" => "idle",
        "logs" => [],
        "updated_at" => nil
      }
    end

    def store
      if Rails.cache.is_a?(ActiveSupport::Cache::NullStore)
        @test_store ||= ActiveSupport::Cache::MemoryStore.new
      else
        Rails.cache
      end
    end
  end
end
