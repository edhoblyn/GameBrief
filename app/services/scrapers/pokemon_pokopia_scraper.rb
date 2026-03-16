require "json"
require "open-uri"
require "nokogiri"

class Scrapers::PokemonPokopiaScraper
  include Scrapers::PublishedAtExtraction
  include Scrapers::StructuredContentExtraction

  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }.freeze
  MICROSITE_LAUNCH_DATE = Time.zone.local(2026, 3, 5)
  PRESS_RELEASE_URL = "https://press.pokemon.com/en/releases/Pokemon-Reveals-Two-New-Video-Game-Experiences-Pokemon-Pokopia-and-Pok"
  NINTENDO_NEWS_URL = "https://www.nintendo.com/us/whatsnew/catch-a-cozy-new-video-about-pokemon-pokopia/"
  MICROSITE_URL = "https://pokopia.pokemon.com/en-us/"

  SOURCES = [
    {
      url: PRESS_RELEASE_URL,
      parser: :fetch_press_release
    },
    {
      url: NINTENDO_NEWS_URL,
      parser: :fetch_nintendo_news
    },
    {
      url: MICROSITE_URL,
      parser: :fetch_microsite_page,
      title: "Pokémon Pokopia Official Site Overview",
      published_at: MICROSITE_LAUNCH_DATE
    },
    {
      url: "#{MICROSITE_URL}explore/",
      parser: :fetch_microsite_page,
      title: "Explore | Pokémon Pokopia",
      published_at: MICROSITE_LAUNCH_DATE
    },
    {
      url: "#{MICROSITE_URL}create/",
      parser: :fetch_microsite_page,
      title: "Create | Pokémon Pokopia",
      published_at: MICROSITE_LAUNCH_DATE
    },
    {
      url: "#{MICROSITE_URL}discover/",
      parser: :fetch_microsite_page,
      title: "Discover | Pokémon Pokopia",
      published_at: MICROSITE_LAUNCH_DATE
    },
    {
      url: "#{MICROSITE_URL}buy-now/",
      parser: :fetch_microsite_page,
      title: "Buy Now | Pokémon Pokopia",
      published_at: MICROSITE_LAUNCH_DATE
    }
  ].freeze

  def call
    SOURCES.map { |source| send(source.fetch(:parser), source) }.compact
  end

  private

  def fetch_press_release(source)
    doc = fetch_document(source.fetch(:url))
    title = doc.at("h1[itemprop='name headline'], h1")&.text&.squish
    content = extract_structured_content(doc, selectors: [".bodytext", "#pressreleaseContent", "article"], title: title)
    published_at = extract_published_at(doc) || parse_published_at(doc.at(".date")&.[]("content") || doc.at(".date")&.text)

    build_patch(title:, content:, source_url: source.fetch(:url), published_at:)
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "PokemonPokopiaScraper: failed to fetch press release #{source.fetch(:url)} - #{e.message}"
    nil
  end

  def fetch_nintendo_news(source)
    doc = fetch_document(source.fetch(:url))
    payload = extract_next_data(doc)
    article = payload.dig("props", "pageProps", "newsArticle") || {}
    title = extract_json_ld_headline(doc) || article["title"].to_s.squish.presence || doc.at("meta[property='og:title']")&.[]("content")&.squish || doc.at("title")&.text&.squish
    content = extract_structured_content(doc, selectors: ["main", "article"], title: title) || build_content_from_rich_text(article.dig("body", "json"))
    published_at = extract_published_at(doc) || extract_published_at_from_object(article)

    build_patch(title:, content:, source_url: source.fetch(:url), published_at:)
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "PokemonPokopiaScraper: failed to fetch Nintendo news #{source.fetch(:url)} - #{e.message}"
    nil
  end

  def fetch_microsite_page(source)
    doc = fetch_document(source.fetch(:url))
    title = source.fetch(:title)
    content = extract_structured_content(doc, selectors: ["main"], title: nil)

    build_patch(
      title: title,
      content: content,
      source_url: source.fetch(:url),
      published_at: source.fetch(:published_at)
    )
  rescue OpenURI::HTTPError => e
    Rails.logger.warn "PokemonPokopiaScraper: failed to fetch microsite #{source.fetch(:url)} - #{e.message}"
    nil
  end

  def fetch_document(url)
    Nokogiri::HTML(URI.open(url, HEADERS))
  end

  def extract_next_data(doc)
    script = doc.at("script#__NEXT_DATA__")
    return {} if script.blank?

    JSON.parse(script.text)
  rescue JSON::ParserError
    {}
  end

  def extract_json_ld_headline(doc)
    doc.css("script[type='application/ld+json']").each do |script|
      payload = JSON.parse(script.text)
      headline = extract_text_value_from_object(payload, ["headline"])
      return headline if headline.present?
    rescue JSON::ParserError
      next
    end

    nil
  end

  def extract_text_value_from_object(object, keys)
    case object
    when Array
      object.each do |entry|
        value = extract_text_value_from_object(entry, keys)
        return value if value.present?
      end
    when Hash
      keys.each do |key|
        value = object[key].to_s.squish.presence
        return value if value.present?
      end

      object.each_value do |value|
        extracted = extract_text_value_from_object(value, keys)
        return extracted if extracted.present?
      end
    end

    nil
  end

  def build_content_from_rich_text(node)
    blocks = extract_rich_text_blocks(node)
    blocks.join("\n").presence
  end

  def extract_rich_text_blocks(node)
    return [] if node.blank?

    case node
    when Array
      node.flat_map { |child| extract_rich_text_blocks(child) }
    when Hash
      node_type = node["nodeType"].to_s

      case node_type
      when "document", "unordered-list", "ordered-list"
        Array(node["content"]).flat_map { |child| extract_rich_text_blocks(child) }
      when "paragraph", /\Aheading-/
        [extract_inline_text(node)].compact
      when "list-item"
        text = extract_inline_text(node)
        text.present? ? ["- #{text}"] : []
      else
        Array(node["content"]).flat_map { |child| extract_rich_text_blocks(child) }
      end
    else
      []
    end
  end

  def extract_inline_text(node)
    return node.to_s.squish unless node.is_a?(Hash)

    if node["nodeType"] == "text"
      node["value"].to_s
    else
      Array(node["content"]).map { |child| extract_inline_text(child) }.join(" ").squish.presence
    end
  end

  def build_patch(title:, content:, source_url:, published_at:)
    return if title.blank? || content.blank?

    {
      title: title,
      content: content,
      source_url: source_url,
      published_at: published_at
    }
  end
end
