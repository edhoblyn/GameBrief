class RunAllPatchScrapesJob < ApplicationJob
  queue_as :default

  def perform(admin_user_id)
    diagnostics = PatchScrapeRunner.run_all_with_diagnostics
    AdminPatchScrapeLogStore.store_diagnostics(admin_user_id, diagnostics)

    failures = diagnostics.count { |entry| !entry.success }
    imported = diagnostics.sum(&:imported)
    skipped = diagnostics.sum(&:skipped)

    Rails.logger.info(
      "RunAllPatchScrapesJob: failures=#{failures} imported=#{imported} skipped=#{skipped}"
    )
  rescue StandardError => e
    AdminPatchScrapeLogStore.store_failure(admin_user_id, e)
    Rails.logger.error("RunAllPatchScrapesJob failed: #{e.class}: #{e.message}")
    raise
  end
end
