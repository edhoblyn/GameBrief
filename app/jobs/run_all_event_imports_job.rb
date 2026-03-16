class RunAllEventImportsJob < ApplicationJob
  queue_as :default

  def perform(admin_user_id)
    diagnostics = EventImportRunner.run_all_with_diagnostics
    AdminEventImportLogStore.store_diagnostics(admin_user_id, diagnostics)

    failures = diagnostics.count { |entry| !entry.success }
    imported = diagnostics.sum(&:imported)
    skipped  = diagnostics.sum(&:skipped)

    Rails.logger.info(
      "RunAllEventImportsJob: failures=#{failures} imported=#{imported} skipped=#{skipped}"
    )
  rescue StandardError => e
    AdminEventImportLogStore.store_failure(admin_user_id, e)
    Rails.logger.error("RunAllEventImportsJob failed: #{e.class}: #{e.message}")
    raise
  end
end
