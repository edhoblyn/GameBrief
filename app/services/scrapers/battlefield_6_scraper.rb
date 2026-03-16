require "open-uri"
require "nokogiri"

class Scrapers::Battlefield6Scraper
  include Scrapers::PublishedAtExtraction

  BASE_URL = "https://www.ea.com".freeze
  INDEX_URL = "#{BASE_URL}/en/games/battlefield/battlefield-6/news".freeze
  HEADERS = {
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
  }.freeze
  RECENT_WINDOW = 6.months.freeze
  GAME_UPDATE_CATEGORY = "Game Updates".freeze
  COMMUNITY_UPDATE_PATTERN = /community update/i
  CONTENT_SELECTORS = "h2, h3, p, li".freeze

  def call
    fetch_article_cards.map do |card|
      fetch_article(card)
    end.compact
  end

  private

  def fetch_document(url)
    Nokogiri::HTML(URI.open(url, HEADERS))
  end

  def fetch_article_cards
    doc = fetch_document(INDEX_URL)

    doc.css("a").filter_map do |link|
      href = link["href"].to_s
      next unless href.include?("/games/battlefield/battlefield-6/news/")

      card = parse_card(link)
      next if card.nil?
      next unless relevant_article?(card)
      next if card[:published_at].present? && card[:published_at] < RECENT_WINDOW.ago.beginning_of_day

      card
    end
  end

  def parse_card(link)
    body = link.css("div").find do |node|
      node.element_children.any? { |child| child.name == "h3" }
    end || link
    title = body.at_css("h3")&.text&.squish
    return if title.blank?
    category = body.element_children.find { |node| node.name == "div" }&.text&.squish

    {
      title: title,
      category: category,
      source_url: normalize_url(link["href"]),
      published_at: parse_published_at(body.at_css("span")&.text)
    }
  end

  def relevant_article?(card)
    card[:category] == GAME_UPDATE_CATEGORY || card[:title].match?(COMMUNITY_UPDATE_PATTERN)
  end

  def fetch_article(card)
    doc = fetch_document(card[:source_url])
    title = doc.at("h1")&.text&.squish.presence || card[:title]
    content = extract_content(doc, title: title)
    return nil if title.blank? || content.blank?

    {
      title: title,
      content: content,
      source_url: card[:source_url],
      published_at: extract_published_at(doc) || card[:published_at]
    }
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "Battlefield6Scraper: failed to fetch #{card[:source_url]} - #{e.message}"
    nil
  end

  def extract_content(doc, title:)
    section = doc.css("section[class*='Section_section']").find do |candidate|
      candidate.css("[class*='articleSlug_articleTypography']").any?
    end
    return if section.blank?

    cleaned = section.dup
    cleaned.css("button, a, svg").remove

    blocks = cleaned.css(CONTENT_SELECTORS).filter_map do |element|
      text = element.text.to_s.squish
      next if text.blank?
      next if text == title
      next if text.match?(/\ATABLE OF CONTENTS:?\z/i)

      element.name == "li" ? "- #{text}" : text
    end

    blocks = blocks.each_with_object([]) do |block, items|
      items << block unless items.last == block
    end

    blocks.join("\n").presence
  end

  def normalize_url(href)
    return if href.blank?
    return href if href.start_with?("http")

    URI.join(BASE_URL, href).to_s
  end
end
