class Admin::EventImportsController < Admin::BaseController

  def create
    source = params.require(:source)
    config = EventImportRunner.fetch(source)

    unless EventImportRunner.manual_trigger_enabled?(source)
      redirect_back(
        fallback_location: admin_dashboard_path,
        alert: config[:disabled_message] || "#{config[:label]} events are seeded manually and cannot be triggered here."
      )
      return
    end

    result = EventImportRunner.run(source)
    store_import_logs([EventImportRunner.diagnostic_for_result(result)])

    redirect_back(
      fallback_location: admin_dashboard_path,
      notice: "#{result.label} event import finished: #{result.imported} imported, #{result.skipped} skipped."
    )
  rescue KeyError
    redirect_back(fallback_location: admin_dashboard_path, alert: "Unknown event import source.")
  rescue ActiveRecord::RecordNotFound => e
    config = EventImportRunner.fetch(params[:source])
    store_import_logs([EventImportRunner.diagnostic_for_error(params[:source], e)])
    redirect_back(fallback_location: admin_dashboard_path, alert: "Game not found: #{e.message}")
  rescue OpenURI::HTTPError => e
    store_import_logs([EventImportRunner.diagnostic_for_error(params[:source], e)])
    redirect_back(fallback_location: admin_dashboard_path, alert: "#{EventImportRunner.fetch(params[:source])[:label]} import failed: #{e.message}")
  rescue StandardError => e
    store_import_logs([EventImportRunner.diagnostic_for_error(params[:source], e)])
    redirect_back(fallback_location: admin_dashboard_path, alert: "Import failed: #{e.message}")
  end

  def run_all
    AdminEventImportLogStore.mark_running(current_user)
    RunAllEventImportsJob.perform_later(current_user.id)

    redirect_to admin_dashboard_path, notice: "All event imports started in the background. Refresh shortly for the latest run output."
  end

  private

  def store_import_logs(diagnostics)
    AdminEventImportLogStore.store_diagnostics(current_user, diagnostics)
  end
end
