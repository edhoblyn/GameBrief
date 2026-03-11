class Patch < ApplicationRecord
  DATE_FILTERS = {
    "all" => "All time",
    "last_7_days" => "Last 7 days",
    "last_30_days" => "Last 30 days",
    "last_90_days" => "Last 90 days",
    "this_year" => "This year"
  }.freeze

  EFFECTIVE_PUBLISHED_AT_SQL = "COALESCE(published_at, created_at)".freeze
  SCRAPED_FIRST_SQL = "CASE WHEN source_url IS NULL THEN 1 ELSE 0 END".freeze

  belongs_to :game
  has_many :patch_summaries, dependent: :destroy
  has_many :chats, dependent: :destroy

  scope :recent_first, -> { order(Arel.sql("#{EFFECTIVE_PUBLISHED_AT_SQL} DESC")) }
  scope :scraped_first_recent_first, -> { order(Arel.sql(SCRAPED_FIRST_SQL), Arel.sql("#{EFFECTIVE_PUBLISHED_AT_SQL} DESC")) }
  scope :with_date_filter, lambda { |filter|
    case filter
    when "last_7_days"
      where("#{EFFECTIVE_PUBLISHED_AT_SQL} >= ?", 7.days.ago.beginning_of_day)
    when "last_30_days"
      where("#{EFFECTIVE_PUBLISHED_AT_SQL} >= ?", 30.days.ago.beginning_of_day)
    when "last_90_days"
      where("#{EFFECTIVE_PUBLISHED_AT_SQL} >= ?", 90.days.ago.beginning_of_day)
    when "this_year"
      where("#{EFFECTIVE_PUBLISHED_AT_SQL} >= ?", Time.zone.today.beginning_of_year)
    else
      all
    end
  }

  def effective_published_at
    published_at || created_at
  end
end
