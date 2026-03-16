require "open-uri"
require "nokogiri"

class Scrapers::Overwatch2Scraper
  include Scrapers::StructuredContentExtraction

  BASE_URL = "https://ga.overwatch.blizzard.com".freeze
  INDEX_URL = "#{BASE_URL}/en-us/news/patch-notes/".freeze
  PATCH_ANCHOR_SELECTOR = "[id^='patch-']".freeze
  PREVIOUS_PAGE_SELECTOR = ".PatchNotesPaginationLink--prev".freeze
  TITLE_PATTERN = /patch notes/i
  MAX_PAGES = 6
  HEADERS = {
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
  }.freeze

  def call
    patches = []
    page_url = INDEX_URL
    visited_page_urls = []

    while page_url.present? && !visited_page_urls.include?(page_url) && visited_page_urls.length < MAX_PAGES
      visited_page_urls << page_url

      doc = fetch_document(page_url)
      page_patches, page_url = parse_page(doc)
      patches.concat(page_patches)
    end

    patches.uniq { |patch| patch[:source_url] }
  end

  private

  def fetch_document(url)
    Nokogiri::HTML(URI.open(url, HEADERS))
  end

  def parse_page(doc)
    patches = doc.css(PATCH_ANCHOR_SELECTOR).filter_map do |anchor|
      build_patch(anchor)
    end

    [patches, normalize_url(doc.at(PREVIOUS_PAGE_SELECTOR)&.[]("href"))]
  end

  def build_patch(anchor)
    sibling_nodes = patch_sibling_nodes(anchor)
    return if sibling_nodes.empty?

    title = sibling_nodes.find { |node| class_name?(node, "PatchNotes-patchTitle") }&.text.to_s.squish
    return if title.blank? || !title.match?(TITLE_PATTERN)

    published_at = extract_published_at(anchor["id"], sibling_nodes)
    content = build_content(sibling_nodes, title: title)
    return if content.blank?

    {
      title: title,
      content: content,
      source_url: source_url_for(anchor_id: anchor["id"], published_at: published_at),
      published_at: published_at
    }
  end

  def patch_sibling_nodes(anchor)
    nodes = []
    sibling = anchor.next_element

    while sibling.present?
      break if class_name?(sibling, "PatchNotesTop")

      nodes << sibling
      sibling = sibling.next_element
    end

    nodes
  end

  def build_content(sibling_nodes, title:)
    blocks = sibling_nodes.filter_map do |node|
      next if class_name?(node, "PatchNotes-labels")
      next if class_name?(node, "PatchNotes-patchTitle")

      extract_text_blocks(node, title: title)
    end

    blocks.reject(&:blank?).join("\n\n")
  end

  def extract_published_at(anchor_id, sibling_nodes)
    label_text = sibling_nodes.find { |node| class_name?(node, "PatchNotes-labels") }&.text.to_s.squish
    parse_date(label_text) || parse_date_from_anchor(anchor_id)
  end

  def parse_date(value)
    return if value.blank?

    Time.zone.parse(value)
  rescue ArgumentError, TypeError
    nil
  end

  def parse_date_from_anchor(anchor_id)
    match = anchor_id.to_s.match(/\Apatch-(\d{4})-(\d{2})-(\d{2})\z/)
    return if match.nil?

    Time.zone.local(match[1].to_i, match[2].to_i, match[3].to_i)
  rescue ArgumentError
    nil
  end

  def source_url_for(anchor_id:, published_at:)
    if published_at.present?
      "#{BASE_URL}/en-us/news/patch-notes/live/#{published_at.year}/#{format('%02d', published_at.month)}##{anchor_id}"
    else
      "#{INDEX_URL}##{anchor_id}"
    end
  end

  def normalize_url(href)
    return if href.blank?

    URI.join(INDEX_URL, href).to_s
  end

  def class_name?(node, class_name)
    node["class"].to_s.split.include?(class_name)
  end
end
