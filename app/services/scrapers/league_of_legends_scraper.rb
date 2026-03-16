require "open-uri"
require "nokogiri"

class Scrapers::LeagueOfLegendsScraper
  include Scrapers::PublishedAtExtraction
  include Scrapers::StructuredContentExtraction

  INDEX_URL = "https://www.leagueoflegends.com/en-us/news/tags/patch-notes/"
  LOOKBACK_WINDOW = 6.months
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
  TITLE_PATTERN = /\bpatch\s+\d+\.\d+\s+notes\b/i

  def call
    patch_entries = fetch_patch_entries
    Rails.logger.info "LeagueOfLegendsScraper: found #{patch_entries.size} patches to import"
    patch_entries.filter_map { |entry| fetch_patch(entry) }
  end

  private

  def fetch_patch_entries
    doc = fetch_document(INDEX_URL)

    doc.css("section[data-testid='article-card-grid'] a[data-testid='articlefeaturedcard-component']").filter_map do |link|
      href = link["href"].to_s.strip
      title = link.at("[data-testid='card-title']")&.text&.squish.presence || link["aria-label"].to_s.squish.presence
      published_at = parse_published_at(link.at("time[datetime]")&.[]("datetime"))

      next if href.blank? || title.blank?
      next unless title.match?(TITLE_PATTERN)
      next if published_at.present? && published_at < lookback_cutoff

      {
        title: title,
        source_url: normalize_url(href),
        published_at: published_at
      }
    end.uniq { |entry| entry[:source_url] }
  end

  def fetch_patch(entry)
    doc = fetch_document(entry[:source_url])
    title = doc.at("h1[data-testid='title'], h1")&.text&.squish.presence || entry[:title]
    content = extract_content(doc, title: title)
    published_at = extract_detail_published_at(doc) || entry[:published_at]

    return nil if title.blank? || content.blank?
    return nil unless title.match?(TITLE_PATTERN)
    return nil if published_at.present? && published_at < lookback_cutoff

    {
      title: title,
      content: content,
      source_url: entry[:source_url],
      published_at: published_at
    }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "LeagueOfLegendsScraper: failed to fetch #{entry[:source_url]} - #{e.message}"
    nil
  end

  def fetch_document(url)
    Nokogiri::HTML(URI.open(url, HEADERS))
  end

  def extract_content(doc, title:)
    candidate = doc.css("section[data-testid='RichTextPatchNotesBlade'] [data-testid='rich-text-html']").max_by do |node|
      node.text.to_s.squish.length
    end

    return extract_text_blocks(candidate, title: title) if candidate.present?

    extract_structured_content(doc, selectors: [
      "section[data-testid='RichTextPatchNotesBlade']",
      "main",
      "article",
      "[data-testid='rich-text-html']"
    ], title: title)
  end

  def extract_detail_published_at(doc)
    parse_published_at(doc.at("section[data-testid='blade'] time[datetime], time[datetime]")&.[]("datetime")) ||
      extract_published_at(doc)
  end

  def lookback_cutoff
    @lookback_cutoff ||= LOOKBACK_WINDOW.ago.beginning_of_day
  end

  def normalize_url(href)
    return href if href.start_with?("http")

    URI.join(INDEX_URL, href).to_s
  end
end
