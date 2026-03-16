class Admin::DashboardController < Admin::BaseController
  def show
    @admins = User.admins.order(Arel.sql("COALESCE(NULLIF(username, ''), email) ASC"))
    @chat_count = Chat.count
    @message_count = Message.count

    @latest_scrape_run = AdminPatchScrapeLogStore.fetch(current_user)
    @scrape_logs = Array(@latest_scrape_run["logs"])
    @scrape_log_status = @latest_scrape_run["status"]

    @latest_event_run = AdminEventImportLogStore.fetch(current_user)
    @event_logs = Array(@latest_event_run["logs"])
    @event_log_status = @latest_event_run["status"]

    @game_cards = build_game_cards
  end

  private

  def build_game_cards
    patch_by_slug = {}
    PatchScrapeRunner.sources.each do |source|
      config = PatchScrapeRunner.fetch(source)
      slug = config.fetch(:game_slugs, []).first
      next unless slug
      patch_by_slug[slug] = { source: source, manual_trigger_enabled: config.fetch(:manual_trigger_enabled, true) }
    end

    event_by_slug = {}
    EventImportRunner.sources.each do |source|
      config = EventImportRunner.fetch(source)
      slug = config.fetch(:game_slugs, []).first
      next unless slug
      event_by_slug[slug] = { source: source, manual_trigger_enabled: config.fetch(:manual_trigger_enabled, true) }
    end

    patch_status_by_source = @scrape_logs.index_by { |e| e["source"] }
    event_status_by_source = @event_logs.index_by { |e| e["source"] }

    all_slugs = (patch_by_slug.keys + event_by_slug.keys).uniq
    games_by_slug = Game.where(slug: all_slugs).index_by(&:slug)

    all_slugs.map do |slug|
      game   = games_by_slug[slug]
      patch  = patch_by_slug[slug]
      event  = event_by_slug[slug]
      label  = game&.name || (patch || event).then { PatchScrapeRunner.fetch(_1[:source])[:label] rescue EventImportRunner.fetch(_1[:source])[:label] rescue slug.humanize }

      patch_log = patch && patch_status_by_source[patch[:source]]
      event_log = event && event_status_by_source[event[:source]]

      {
        slug: slug,
        label: label,
        cover_image: game&.cover_image,
        patch: patch,
        event: event,
        patch_status: patch_log && (patch_log["success"] ? :success : :error),
        event_status: event_log && (event_log["success"] ? :success : :error)
      }
    end.sort_by { |c| c[:label].downcase }
  end
end
