class Patch < ApplicationRecord
  DATE_FILTERS = {
    "all" => "All time",
    "last_7_days" => "Last 7 days",
    "last_30_days" => "Last 30 days",
    "last_90_days" => "Last 90 days",
    "this_year" => "This year"
  }.freeze

  belongs_to :game
  has_many :patch_summaries, dependent: :destroy
  has_many :chats, dependent: :destroy

  scope :recent_first, -> { order(Arel.sql("#{effective_published_at_sql} DESC")) }
  scope :scraped_first_recent_first, -> { order(Arel.sql(scraped_first_sql), Arel.sql("#{effective_published_at_sql} DESC")) }
  scope :with_date_filter, lambda { |filter|
    case filter
    when "last_7_days"
      where("#{effective_published_at_sql} >= ?", 7.days.ago.beginning_of_day)
    when "last_30_days"
      where("#{effective_published_at_sql} >= ?", 30.days.ago.beginning_of_day)
    when "last_90_days"
      where("#{effective_published_at_sql} >= ?", 90.days.ago.beginning_of_day)
    when "this_year"
      where("#{effective_published_at_sql} >= ?", Time.zone.today.beginning_of_year)
    else
      all
    end
  }

  def self.published_at_column?
    columns_hash.key?("published_at")
  end

  def self.effective_published_at_sql
    if published_at_column?
      "#{table_name}.published_at"
    else
      "#{table_name}.created_at"
    end
  end

  def self.scraped_first_sql
    "CASE WHEN #{table_name}.source_url IS NULL THEN 1 ELSE 0 END"
  end

  def self.normalize_imported_published_at(published_at, source_url:)
    return if published_at.blank?
    return published_at unless published_at > Time.zone.now.end_of_day

    inferred_published_at = infer_published_at_from_source_url(source_url)
    return inferred_published_at if inferred_published_at.present? && inferred_published_at <= Time.zone.now.end_of_day

    nil
  end

  def self.infer_published_at_from_source_url(source_url)
    return if source_url.blank?

    full_date_match = source_url.match(%r{/(20\d{2})[/-](\d{2})[/-](\d{2})(?:/|$)})
    return Time.zone.local(full_date_match[1].to_i, full_date_match[2].to_i, full_date_match[3].to_i) if full_date_match

    compact_date_match = source_url.match(%r{/(20\d{2})(\d{2})(\d{2})(?:/|$)})
    return Time.zone.local(compact_date_match[1].to_i, compact_date_match[2].to_i, compact_date_match[3].to_i) if compact_date_match

    year_month_match = source_url.match(%r{/(20\d{2})[/-](\d{2})(?:/|$)})
    return Time.zone.local(year_month_match[1].to_i, year_month_match[2].to_i, 1) if year_month_match
  rescue ArgumentError
    nil
  end

  def self.import_attributes(data, game:, existing_patch:)
    resolved_published_at = if published_at_column?
      normalize_imported_published_at(
        data[:published_at] || existing_patch&.stored_published_at_for_reimport,
        source_url: data[:source_url] || existing_patch&.source_url
      )
    end

    attributes = {
      game: game,
      title: data[:title],
      content: data[:content]
    }

    if published_at_column?
      attributes[:published_at] = resolved_published_at
    end

    attributes
  end

  def effective_published_at
    return created_at unless self.class.published_at_column?

    self[:published_at] || created_at
  end

  def display_published_at
    stored_published_at_for_reimport
  end

  def stored_published_at_for_reimport
    return unless self.class.published_at_column?
    return if self[:published_at].blank?
    normalized_published_at = self.class.normalize_imported_published_at(self[:published_at], source_url: source_url)
    return if normalized_published_at.blank?
    return normalized_published_at if source_url.blank?
    return normalized_published_at if created_at.blank?
    return if self[:published_at].to_i == created_at.to_i

    normalized_published_at
  end
end
